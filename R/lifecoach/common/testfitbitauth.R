
Sys.setenv(NOAWT = "true")
library(httr)
library(rjson)
library('RCurl')

username <- "stefano"
pushoveruser <- "u8JjTgEDJxz2zkkHaK5VM57iDZJsz6"
fitbitkey <- "9b8a4dfbb4684ba5b5fb3b07122e99a7"                          
fitbitsecret <- "27ad03d202d8439eb693d1b8430ceca8"
fitbitappname <- "stefano-fitbit"      

token_url = "http://api.fitbit.com/oauth/request_token"
access_url = "http://api.fitbit.com/oauth/access_token"
auth_url = "http://www.fitbit.com/oauth/authorize"

load(file = paste("fitbit-token.RData", sep = ""), .GlobalEnv)
load(file = paste("fitbit-sig.RData", sep = ""), .GlobalEnv)
sig = sign_oauth1.0(fbr, token=token$oauth_token, token_secret=token$oauth_token_secret)

getURL <- "http://api.fitbit.com/1/user/-/body/log/weight/date/2014-03-30.json"
weightJSON <- tryCatch({
  GET(getURL, sig)
}, warning = function(w) {
  print("Warning weight")
  stop()
}, error = function(e) {
  print("Error weight")
  stop()
}, finally = {
})
   
getURL <- "http://api.fitbit.com/1/user/-/activities/steps/date/"
#startdate <- Sys.Date() - 7
startdate <- "2014-04-01"
startdatestr <- as.POSIXct(startdate, format = "%a %b %d")
getURL <- paste(getURL, startdate, "/today.json", sep = "")

# get all step data from my first day of use to the current date:
stepsJSON <- tryCatch({
  GET(getURL, sig)
}, warning = function(w) {
  print("Warning steps")
  stop()
}, error = function(e) {
  print("Error steps")
  stop()
}, finally = {
})


