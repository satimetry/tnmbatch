#!/usr/bin/Rscript

# Batch control script
Sys.setenv(NOAWT = "true")

#rooturl <<- "http://localhost:8080/tnm/rest"
rooturl <<- "http://nudgeserver-spicozzi.rhcloud.com/tnm/rest"
rootdir <<- "~/tnm/tnmbatch/R/lifecoach/dowithings"
imagesdir <<- "~/websites/nudge/images"
setwd(rootdir)
ppi <<- 300

source("../common/common.R")

# Do programid=1 and weight observations
programid <<- 1

# Get programusers enrolled for this programid
programusers <- getProgramuser(rooturl, programid)

for (programuser in programusers) {

   userid <<- programuser["userid"]

   if ( userid != 7 ) { next }

   print(paste("--->INSERTOBS --", userid, sep = ""))
   source("dowithingsobs.R", echo = TRUE )
   
   obsname <<- "bmi"
   rulename <<- "bmi"
   print(paste("--->APPLYNUDGES --", userid, sep = ""))
   source("../common/donudges.R", echo = TRUE )
      
   print(paste("--->PUSHNOTIFICATION :", userid, sep = ""))
   source("../common/donotifications.R", echo = TRUE )
   
   print(paste("--->PLOTS :", userid, sep = ""))
   source("dowithingsplots.R", echo = TRUE )

   obsname <<- "weight"
   print(paste("--->PLOTS :", userid, sep = ""))
   source("dowithingsplots.R", echo = TRUE )
   
}
