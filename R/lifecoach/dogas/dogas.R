#!/usr/bin/Rscript

# Batch control script
Sys.setenv(NOAWT = "true")

#rooturl <<- "http://localhost:8080/tnm/rest"
rooturl <<- "http://nudgeserver-spicozzi.rhcloud.com/tnm/rest"
rootdir <<- "~/websites/nudge/R/lifecoach/dogas"
imagesdir <<- "~/websites/nudge/images"
setwd(rootdir)
ppi <<- 300

source("../common/common.R")

# Do programid=1 and activity observations
programid <<- 1

# Get programusers enrolled for this programid
programusers <- getProgramuser(rooturl, programid)

for (programuser in programusers) {
  
  userid <<- programuser["userid"]
  
  if ( userid != 7 ) { next }
   
  pollidlist <<- c(15, 16, 18)
  # pollidlist <<- c(15)
  for (polliditem in pollidlist) {
    
    pollid <<- polliditem
    if ( pollid == 15 ) { gastype <<- "gas11" }
    if ( pollid == 16 ) { gastype <<- "gas12" }
    if ( pollid == 18 ) { gastype <<- "gas21" }
    
    obsname <<- gastype
    rulename <<- "gas"
    print(paste("--->APPLYNUDGES: ", userid, "-", obsname, sep = ""))
    source("../common/donudges.R", echo = TRUE )
    
    print(paste("--->PLOTS: ", userid, "-", obsname, sep = ""))
    source("dogasplots.R", echo = TRUE )
  }
   
  print(paste("--->PUSHNOTIFICATION: ", userid, sep = ""))
  source("../common/donotifications.R", echo = TRUE )
   
}
