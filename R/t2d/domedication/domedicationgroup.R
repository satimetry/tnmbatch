#!/usr/bin/Rscript

# Batch control script
Sys.setenv(NOAWT = "true")

#rooturl <<- "http://localhost:8080/tnm/rest"
rooturl <<- "http://nudgeserver-spicozzi.rhcloud.com/tnm/rest"
rootdir <<- "~/tnm/tnmbatch/R/t2d/domedication"
imagesdir <<- "~/websites/nudge/images"
setwd(rootdir)
ppi <<- 300

source("../../common/common.R")

# Do programid=2 and medicate observations
programid <<- 2
obsname <<- "medicate"
rulename <<- "medicate"
groupid <<- 0

print(paste("--->APPLYNUDGES: ", obsname, sep = ""))
source("../../common/donudgesgroup.R", echo = TRUE )

programusers <- getProgramuser(rooturl, programid)
for (programuser in programusers) {
   if (programuser$roletype != "participant") { next }
   userid <- programuser["userid"]  
   print(paste("--->PUSHNOTIFICATION: ", sep = ""))
   source("../../common/donotifications.R", echo = TRUE )
}
