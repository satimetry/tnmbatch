# Pull down observations and insert into database

rootdir <- "/Users/stefanopicozzi/websites/nudge"
user <- "stefano"
ppi <- 300
userid <- "7"
programid <- "1"
wd <- paste(rootdir, "/R/fitbit/user/", user, sep="")
setwd(wd)

Sys.setenv(NOAWT = "true")
library(httr)
library(rjson)
library("RMySQL")

token_url = "http://api.fitbit.com/oauth/request_token"
access_url = "http://api.fitbit.com/oauth/access_token"
auth_url = "http://www.fitbit.com/oauth/authorize"
key = "9b8a4dfbb4684ba5b5fb3b07122e99a7"
secret = "27ad03d202d8439eb693d1b8430ceca8"

fbr = oauth_app('stefano-fitbit',key,secret)
fitbit = oauth_endpoint(token_url,auth_url,access_url)
#token = oauth1.0_token(fitbit,fbr)
#sig = sign_oauth1.0(fbr, token=token$oauth_token, token_secret=token$oauth_token_secret)

#save(token, file="fitbit-token.RData")
#save(sig, file="fitbit-sig.RData")

load(file = "fitbit-token.RData", .GlobalEnv)
load(file = "fitbit-sig.RData", .GlobalEnv)

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

#con <- dbConnect(dbDriver("MySQL"), host = "127.0.0.1", port=3307, dbname = "nudge", user = "admin6nZaW9E", password = "mJbS__JPs_mt")
#con <- dbConnect(dbDriver("MySQL"), host = "127.0.0.1", port=3306, dbname = "nudge", user = "root", password = "")

dbListTables(con)

sqlStmt <- "DELETE FROM userobs where userid = 7";
result <- dbGetQuery(con, sqlStmt)

for (i in 1:nrow(inputDF)) { 

   username <- inputDF[i, "username"]
   obsname <- "'activity'"
   obsdate <- inputDF[i, "obsdate"]
   obsdate <- paste("'", obsdate, "'", sep="")
   obsvalue <- paste("'", inputDF[i, "obsvalue"], "'", sep="")

   sqlStmt <- paste(
      " INSERT INTO userobs (userid, programid, obsname, obsdate, obsvalue)",
      "  VALUES (", 
      userid, ", ",
      programid, ", ",
      obsname, ", ",
      obsdate, ", ",
      obsvalue, "); ",   
      sep = "")

   print(sqlStmt)   
   result <- dbGetQuery(con, sqlStmt)
   Sys.sleep(2)
   result <- dbGetQuery(con, "COMMIT;")
}

#dbDisconnect(con)



