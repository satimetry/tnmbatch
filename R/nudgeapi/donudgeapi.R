# Batch control script
Sys.setenv(NOAWT = "true")
library('rjson')
library("RMySQL")
library('httr')
library('RCurl')

rootdir <<- "/Users/stefanopicozzi/websites/nudge/R/nudgeapi"
imagesdir <<- "/Users/stefanopicozzi/websites/nudge/R/nudgeapi/images"
rooturl <<- "http://nudgeserver-spicozzi.rhcloud.com/tnm/rest"
#rooturl <<- "http://localhost:8080/tnm/rest"

setwd(rootdir)
programid <<- 5
ppi <<- 300
userid <<- 7
username <<- "stefano"
user <<- username
key <<- "9b8a4dfbb4684ba5b5fb3b07122e99a7"
secret <<- "27ad03d202d8439eb693d1b8430ceca8"
appname <<- "stefano-fitbit"
pushoveruser <<- "u8JjTgEDJxz2zkkHaK5VM57iDZJsz6"

token_url = "http://api.fitbit.com/oauth/request_token"
access_url = "http://api.fitbit.com/oauth/access_token"
auth_url = "http://www.fitbit.com/oauth/authorize"

fbr = oauth_app(appname, key, secret)
fitbit = oauth_endpoint(token_url, auth_url, access_url)

load(file = paste("fitbit-token.RData", sep = ""), .GlobalEnv)
load(file = paste("fitbit-sig.RData", sep = ""), .GlobalEnv)

# get fitbit step activity data
getURL <- "http://api.fitbit.com/1/user/-/activities/steps/date/"
startdate <- "2014-01-01"
#startdate <- "2014-02-20"
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
   
# Remove all user generated facts for this program and group
result <- tryCatch({  
   getURL(paste(rooturl, "/fact/del?programid=",programid, "&groupid=", userid, sep=""))
}, warning = function(w) {
   print("Warning")
}, error = function(e) {
   print("Error")
}, finally = {
})

# Populate user facts using fitbit data
for (i in 1:nrow(inputDF)) { 
   
   username <- inputDF[i, "username"]
   username <- paste("\"", username, "\"", sep="")
   obsname <- "\"activity\""
   obsdate <- inputDF[i, "obsdate"]
   obsdate <- paste("\"", obsdate, "\"", sep="")
   obsvalue <- paste(inputDF[i, "obsvalue"], sep="")
   obsdesc <- "\"System generated from fitbit.com step-count download\"";

   factjson <- URLencode(paste('{ \"username\":', username, 
                ', \"obsname\":', obsname, 
                ', \"obsdate\":', obsdate, 
                ', \"obsvalue\":', obsvalue,
                ', \"obsdesc\":', obsdesc, '}' ))

   
   params <- paste("programid=", programid, "&groupid=", userid, "&factjson=", factjson, sep="")
   url <- paste("curl -X POST --data '", params, "' ", rooturl, "/fact", sep="")
#   params <- list(programid=programid, groupid=userid, factjson=factjson)
   
   result <- tryCatch({
 
#      response = postForm(paste(rooturl, "/fact ", sep=""), .params = params, binary=FALSE)
      system(url)
      print(factjson)
   }, warning = function(w) {
      print("Warning")
      stop()
   }, error = function(e) {
      print("Error")
      stop()
   }, finally = {
   })
 
}

# nudge this program and group
result <- tryCatch({  
   facts <- getURL(paste(rooturl, "/nudge?", "programid=", programid, "&groupid=", userid, "&rulename=donudgeapi", sep=""))
}, warning = function(w) {
   print("Warning")
}, error = function(e) {
   print("Error")
}, finally = {
})


# Get all user generated facts for this program and group
result <- tryCatch({  
   facts <- getURL(paste(rooturl, "/fact/user?", "programid=", programid, "&groupid=", userid, sep=""))
}, warning = function(w) {
   print("Warning")
}, error = function(e) {
   print("Error")
}, finally = {
})
facts <- fromJSON(facts)
userfactsDF <- as.data.frame(do.call(rbind, facts))

# Get all system generated facts for this program and group
result <- tryCatch({  
   facts <- getURL(paste(rooturl, "/fact/system?", "programid=", programid, "&groupid=", userid, sep=""))
}, warning = function(w) {
   print("Warning")
}, error = function(e) {
   print("Error")
}, finally = {
})
facts <- fromJSON(facts)
systemfactsDF <- as.data.frame(do.call(rbind, facts))

# send nudges via pushover.net
print(systemfactsDF)
today <- Sys.Date()

for (fact in facts) {

   msg <- paste(fromJSON(fact$factjson)$rulemsg, ". To opt-out from nudges visit: ", "http://www.satimetry.com/rulesettings.php", sep = "")       
   print(msg)
      
   curl_cmd = paste(
      "curl -s",
      " -F \"token=acqa2Xgn6Fj7NsctUaxqPm8ngURksP\" ",
      " -F \"user=", pushoveruser, "\" ",
      " -F \"message=", msg, "\" ",
      " https://api.pushover.net/1/messages.json", 
      sep = "")
            
   result <- tryCatch({
      system(curl_cmd)
   }, warning = function(w) {
      print("Warning")
      stop()
   }, error = function(e) {
      print("Error")
      stop()
   }, finally = {
   })
   
}

