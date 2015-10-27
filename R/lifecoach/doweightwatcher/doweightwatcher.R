#!/usr/local/bin/Rscript

# Batch control script
Sys.setenv(NOAWT = "true")

#rooturl <<- "http://localhost:8080/tnm/rest"
rooturl <<- "https://nudgeserver-spicozzi.rhcloud.com/tnm/rest"
rootdir <<- "~/GitHub/tnmbatch/R/lifecoach/dowithings"
containerurl <<- "http://192.168.59.103:8080"

setwd("~/GitHub/tnmbatch/R/lifecoach")
source("../common/common.R")

# Do programid=1 and weight observations
programid <<- 1

# Get programusers enrolled for this programid
programusers <- getProgramuser(rooturl, programid)

for (programuser in programusers) {

   userid <<- programuser["userid"]

#   if ( userid != 7 && userid != 58 ) { next }
   if ( userid != 7 ) { next }

   print(paste("--->WEIGHTWATCHER --", userid, sep = ""))
   tryCatch({
      source("doweightwatcher/weightwatcher.R", echo = TRUE )
   }, error = function(err) {
      print(geterrmessage())
   }, finally = {
   })

}
