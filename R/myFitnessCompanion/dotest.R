# Pull down observations and insert into database

Sys.setenv(NOAWT = "true")
library('httr')
library('rjson')
library('RCurl')

rootdir <- "~/tnm/tnmbatch/R/myFitnessCompanion"
setwd(rootdir)
source("../common/common.R")

programid <- 9
userid <- 97
username <- "StefanoPicozzi@gmail.com"
rooturl <<- "https://nudgeserver-spicozzi.rhcloud.com/tnm/rest"

obsname <- "\"weight\""
obsvalue <- 77
#obsdate="\"2015-01-01 07\:30\:00\""
obsdate="\"2015-01-01\""
obsdesc <- "\"Nudge website entry using Nudge API\""

# obsname= "\"weight\""
# obsdesc = "\"System generated from fitbit.com weight download\""                

userobs <- c(programid=programid,
             userid=userid,
             obsname=obsname,
             obsdate=obsdate,
             obsvalue=obsvalue,
             obsdesc=obsdesc              
)
postUserobs(rooturl, userobs)


