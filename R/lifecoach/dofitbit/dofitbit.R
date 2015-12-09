#!/usr/local/bin/Rscript

# Batch control script
Sys.setenv(NOAWT = "true")

setwd("~/GitHub/tnmbatch/R/lifecoach")
source("../common/common.R")

# Get programusers enrolled for this programid
programusers <- getProgramuser(rooturl, programid)

for (programuser in programusers) {

   userid <<- programuser["userid"]

#   if ( userid != 7 && userid != 58 ) { next }   
   if ( userid != 7 ) { next }
   
   print(paste("--->INSERTOBS --", userid, sep = ""))
   source("dofitbit/dofitbitobs.R", echo = TRUE )

   obsname <<- "activity"
   rulename <<- "activity"
   print(paste("--->APPLYNUDGES --", userid, sep = ""))
   # source("../common/donudges.R", echo = TRUE )

   print(paste("--->PUSHNOTIFICATION :", userid, sep = ""))
   # source("../common/donotifications.R", echo = TRUE )

   print(paste("--->PLOTS :", userid, sep = ""))
   source("dofitbit/dofitbitplots.R", echo = TRUE )

}
