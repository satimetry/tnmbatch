# Batch control script
Sys.setenv(NOAWT = "true")
library('rjson')
library("RMySQL")
library('httr')
library('RCurl')

#factjson <- URLencode(paste('{ \"username\":', username, 
##                            ', \"obsname\":', obsname, 
##                            ', \"obsdate\":', obsdate, 
#                            ', \"obsvalue\":', obsvalue,
#                            ', \"obsdesc\":', obsdesc, '}' ))


#params <- paste("programid=", programid, "&groupid=", userid, "&factjson=", factjson, sep="")

url <- paste("curl -X POST -H \"Content-Type: application/json\" --data '{ \"name\" : \"Duncan\", \"surname\" : \"Doyle\"}'", " ", "http://localhost:8080/RestfulRulesWeb-1.0.0/rest/rules/fire", sep="")

system(url)

