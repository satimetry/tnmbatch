# Pull down observations and insert into database

Sys.setenv(NOAWT = "true")
library(httr)
library(rjson)
library("RMySQL")

token_url = "http://api.fitbit.com/oauth/request_token"
access_url = "http://api.fitbit.com/oauth/access_token"
auth_url = "http://www.fitbit.com/oauth/authorize"

fbr = oauth_app(appname, key, secret)
fitbit = oauth_endpoint(token_url, auth_url, access_url)
#token = oauth1.0_token(fitbit,fbr)
#sig = sign_oauth1.0(fbr, token=token$oauth_token, token_secret=token$oauth_token_secret)

#save(token, file="fitbit-token.RData")
#save(sig, file="fitbit-sig.RData")

load(file = paste("../user/", user, "/fitbit-token.RData", sep = ""), .GlobalEnv)
load(file = paste("../user/", user, "/fitbit-sig.RData", sep = ""), .GlobalEnv)

getURL <- "http://api.fitbit.com/1/user/-/activities/steps/date/"
#startdate <- Sys.Date() - 7
startdate <- "2014-01-01"
startdatestr <- as.POSIXct(startdate, format = "%a %b %d")
getURL <- paste(getURL, startdate, "/today.json", sep = "")

# get all step data from my first day of use to the current date:
stepsJSON <- tryCatch({
   GET(getURL, sig)
}, warning = function(w) {
   print("Warning")
   stop()
}, error = function(e) {
   print("Error")
   stop()
}, finally = {
})

stepsDF <- NULL
for (i in 1:length(content(stepsJSON)$`activities-steps`)) {
   x = c( content(stepsJSON)$`activities-steps`[i][[1]][['dateTime']], content(stepsJSON)$`activities-steps`[i][[1]][['value']] ) 
   stepsDF <- cbind(stepsDF, x)
}
stepsDF <- t(stepsDF)
colnames(stepsDF) = c("obsdate", "obsvalue")
stepsDF = as.data.frame(stepsDF, row.names = 1)

inputDF <- cbind( username = c(user), stepsDF)
inputDF <- data.frame(lapply(inputDF, as.character), stringsAsFactors=FALSE)

dbListTables(con)

sqlStmt <- paste("DELETE FROM userobs where obsname='activity' and userid=", userid, " and programid=", programid, " ;", sep = "");
result <- dbGetQuery(con, sqlStmt)

for (i in 1:nrow(inputDF)) { 

   username <- inputDF[i, "username"]
   obsname <- "'activity'"
   obsdate <- inputDF[i, "obsdate"]
   obsdate <- paste("'", obsdate, "'", sep="")
   obsvalue <- paste("'", inputDF[i, "obsvalue"], "'", sep="")
   obsdesc <- "'System generated from fitbit.com step-count download'";
   
   sqlStmt <- paste(
      " INSERT INTO userobs (userid, programid, obsname, obsdate, obsvalue, obsdesc)",
      "  VALUES ",
      "(", 
      userid, ", ",
      programid, ", ",
      obsname, ", ",
      obsdate, ", ",
      obsvalue, ", ",
      obsdesc,
      "); ",   
      sep = "")

   print(sqlStmt)   
   result <- dbGetQuery(con, sqlStmt)
   Sys.sleep(1)
   result <- dbGetQuery(con, "COMMIT;")
}
