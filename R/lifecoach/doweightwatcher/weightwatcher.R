
Sys.setenv(NOAWT = "true")
library('httr')
library('rjson')
library('RCurl')
library('XML')

# Default test case
if ( !exists("userid") ) { userid <- 7 }
if ( !exists("programid") ) { programid <- 1 }
if ( !exists("containerurl") ) {
  #url <- "http://localhost:8080"
  containerurl <- "http://192.168.59.103:8080"
  #url <- "http://127.0.0.1:8080"
  #url <- "http://54.153.151.37:8080"
}

setwd("~/GitHub/tnmbatch/R/lifecoach")
source("../common/container.R")

# Get user details for userid
user <- getUser(rooturl, userid)
username <- user['username']
pushoveruser <- user['pushoveruser']
fitbitkey <- user['fitbitkey']
fitbitsecret <- user['fitbitsecret']
fitbitappname <- user['fitbitappname']

weightDF <- getWeightObservations( username, fitbitkey, fitbitsecret, fitbitappname )

containerurl <- paste( containerurl, "/kie-server/services/rest/server/containers/instances/watch", sep = "" )

#response <- putKIEContainer( containerurl )
#print (response)

request <- buildNudgeRequest( userid = userid, username, weightDF )
list <- postNudgeRequest( containerurl, request )

for ( i in 2:(length(list$result)-2) ) {
  msgtxt <- as.character( list$result[[i]]$com.redhat.weightwatcher.Fact$facttxt )
  msgtxt <- paste(msgtxt, ". To opt-out from nudges visit: ", "http://www.thenudgemachine.com/rulesettings.php", sep = "")
  sendPushover(pushoveruser, msgtxt)
  print( msgtxt )
}

#length <- length(list)-2
#for ( i in 2:length ) {
#  msgtxt <- as.character( list[[i]]$com.redhat.weightwatcher.Fact$facttxt )
#  msgtxt <- paste(msgtxt, ". To opt-out from nudges visit: ", "http://www.thenudgemachine.com/rulesettings.php", sep = "")
#  sendPushover(pushoveruser, msgtxt)
#  print( msgtxt )
#}
