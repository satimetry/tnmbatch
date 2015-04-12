#!/usr/bin/Rscript

# Batch control script
Sys.setenv(NOAWT = "true")

#rooturl <<- "http://localhost:8080/tnm/rest"
rooturl <<- "http://nudgeserver-spicozzi.rhcloud.com/tnm/rest"
rootdir <<- "~/TheNudgeMachine/GitHub/tnmbatch/R/myFitnessCompanion/dogas"
imagesdir <<- "~/TheNudgeMachine/OpenShift/nudge/images"
ppi <<- 300

setwd("~/TheNudgeMachine/GitHub/tnmbatch/R/myFitnessCompanion")
source("../common/common.R")

# Do programid=9 and gas observations
programid <<- 9

# Get programusers enrolled for this programid
programusers <- getProgramuser(rooturl, programid)

gaslist <- c("gas11")
for (programuser in programusers) {
  
   if (programuser$roletype != "participant") { next }
   
   userid <<- programuser["userid"]
  
   for (gas in gaslist) {
      gastype <- "gas11" 

      print(paste("--->APPLYNUDGES: ", userid, "-", gastype, sep = ""))
      tryCatch({
         obsname <<- gastype
         rulename <<- "gas"
         source("../common/donudges.R", echo = TRUE )
      }, error = function(err) {
         print(geterrmessage())
      }, finally = {   
      })
    
      print(paste("--->PLOTS: ", userid, "-", gastype, sep = ""))
      tryCatch({
          obsname <<- gastype
         source("dogas/dogasplots.R", echo = TRUE )
      }, error = function(err) {
          print(geterrmessage())
      }, finally = {   
      })

   }
   
   print(paste("--->PUSHNOTIFICATION: ", userid, sep = ""))
    tryCatch({
        source("../common/donotifications.R", echo = TRUE )
   }, error = function(err) {
        print(geterrmessage())
   }, finally = {   
   })

}
