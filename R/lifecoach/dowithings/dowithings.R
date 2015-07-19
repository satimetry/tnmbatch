#!/usr/bin/Rscript

# Batch control script
Sys.setenv(NOAWT = "true")

#rooturl <<- "http://localhost:8080/tnm/rest"
rooturl <<- "https://nudgeserver-spicozzi.rhcloud.com/tnm/rest"
rootdir <<- "~/TheNudgeMachine/GitHub/tnmbatch/R/lifecoach/dowithings"

setwd("~/TheNudgeMachine/GitHub/tnmbatch/R/lifecoach")
source("../common/common.R")

# Do programid=1 and weight observations
programid <<- 1

# Get programusers enrolled for this programid
programusers <- getProgramuser(rooturl, programid)

for (programuser in programusers) {

   userid <<- programuser["userid"]

#   if ( userid != 7 && userid != 58 ) { next }
   if ( userid != 7 ) { next }
   
   print(paste("--->INSERTOBS WEIGHT --", userid, sep = ""))
   tryCatch({
      source("dowithings/dowithingsobs-weight.R", echo = TRUE )
   }, error = function(err) {
      print(geterrmessage())
   }, finally = {   
   })

   print(paste("--->INSERTOBS FAT --", userid, sep = ""))
   tryCatch({
      source("dowithings/dowithingsobs-fat.R", echo = TRUE )
   }, error = function(err) {
      print(geterrmessage())
   }, finally = {   
   })

   print(paste("--->APPLYNUDGES --", userid, sep = ""))
   tryCatch({
      obsname <<- "bmi"
      rulename <<- "bmi"
      print(obsname)
      source("../common/donudges.R", echo = TRUE )
   }, error = function(err) {
      print(geterrmessage())
   }, finally = {   
   })

   print(paste("--->APPLYNUDGES --", userid, sep = ""))
   tryCatch({
      obsname <<- "weight"
      rulename <<- "weight"
      print(obsname)
      source("../common/donudges.R", echo = TRUE )      
   }, error = function(err) {
      print(geterrmessage())
   }, finally = {   
   })

   print(paste("--->PUSHNOTIFICATION :", userid, sep = ""))
   tryCatch({
      source("../common/donotifications.R", echo = TRUE )
   }, error = function(err) {
      print(geterrmessage())
   }, finally = {   
   })

   print(paste("--->PLOTS :", userid, sep = ""))
   tryCatch({
      obsname <<- "bmi"
      print(obsname)
      source("dowithings/dowithingsplots.R", echo = TRUE )
   }, error = function(err) {
      print(geterrmessage())
   }, finally = {   
   })

   print(paste("--->PLOTS :", userid, sep = ""))
   tryCatch({
      obsname <<- "weight"
      print(obsname)
      source("dowithings/dowithingsplots.R", echo = TRUE )
   }, error = function(err) {
      print(geterrmessage())
   }, finally = {   
   })

   print(paste("--->PLOTS :", userid, sep = ""))
   tryCatch({
      obsname <<- "fat"
      print(obsname)
      source("dowithings/dowithingsplots.R", echo = TRUE )
   }, error = function(err) {
      print(geterrmessage())
   }, finally = {   
   })

}
