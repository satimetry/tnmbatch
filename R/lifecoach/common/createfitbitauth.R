# This script will generate reusable fitbit authentication files
# The sxript will trigger a browser page to be launched in which you enter Allow

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

fbr = oauth_app(fitbitappname, fitbitkey, fitbitsecret)
fitbit = oauth_endpoint(token_url, auth_url, access_url)
   
token = oauth1.0_token(fitbit,fbr)
sig = sign_oauth1.0(fbr, token=token$oauth_token, token_secret=token$oauth_token_secret)

save(token, file="fitbit-token.RData")
save(sig, file="fitbit-sig.RData")
