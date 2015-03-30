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

# Get programusers enrolled for this programid
programusers <- getProgramuser(rooturl, programid)

for (programuser in programusers) {
  
   if (programuser$roletype != "participant") { next }
   userid <<- programuser["userid"]
   # if (userid != 60) {next}
   
   obsname <<- "medicate"
   rulename <<- "medicate"
  
   print(paste("--->APPLYNUDGES: ", userid, "-", obsname, sep = ""))
   source("../../common/donudges.R", echo = TRUE )

   print(paste("--->PUSHNOTIFICATION: ", userid, sep = ""))
   source("../../common/donotifications.R", echo = TRUE )
 
}
