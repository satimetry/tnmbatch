# Pull down observations and apply all rules
Sys.setenv(NOAWT = "true")

library(rjson)

# Get observations for this programid and userid
userobsDF <- getUserobsDF(rooturl, programid, userid, gastype)
userobss <- getUserobs(rooturl, programid, userid, gastype)

delFact <- delFact(rooturl, programid, groupid=userid, factname=gastype)
postFact(rooturl, programid, groupid=userid, factname=gastype, userobsDF)
getNudge(rooturl, programid, groupid=userid, factname=gastype, rulename="donudgeapi")
factouts <- getFactsystem(rooturl, programid, groupid=userid, factname=gastype)

outputDF = c()
for (factout in factouts) {
  outputDF <- cbind(outputDF, c( id=fromJSON(factout$factjson)$id, 
                                 rulename=fromJSON(factout$factjson)$rulename,
                                 ruledate=fromJSON(factout$factjson)$ruledate,
                                 rulemsg=fromJSON(factout$factjson)$rulemsg,
                                 ruledata=fromJSON(factout$factjson)$ruledata))
}
outputDF = t(outputDF)

# Get optinrules for this programid and userid
optinruleviewDF <- getOptinruleviewDF(rooturl, programid, userid)
outputDF <- outputDF[ order(outputDF[, "rulename"]), ]
outputDF <- subset(outputDF, outputDF[, "rulename"] %in% optinruleviewDF )

smsDF <- outputDF
#smsDF <- data.frame(lapply(smsDF, as.character), stringsAsFactors = FALSE)
#stepDateTime <- as.Date(smsDF[, "ruledate"], format = "%a %b %d")
stepDateTime <- as.POSIXct(smsDF[, "ruledate"], format = "%a %b %d %H:%M:%S EST %Y")
#stepDateTime <- as.POSIXct(smsDF$ruledate, format = "%Y-%m-%d")
#stepDateTime <- toString(as.POSIXlt( as.numeric(smsDF[", "ruledate"), origin="1970-01-01 00:00:00" ))
smsDF <-cbind(smsDF, c( stepDateTime = stepDateTime ) )

today <- Sys.Date()

if ( ! is.null(nrow(smsDF)) ) {
  
  for (i in 1:nrow(smsDF)) {
    print(smsDF[i, "rulename" ])  
    
    rule <- getRule(rooturl, smsDF[i, "rulename" ] )
    
    ruledate <- as.POSIXct(smsDF[i, "ruledate" ], format = "%a %b %d")
    
    msg <- c(programid=programid,
             userid,
             ruleid=rule[[1]]$ruleid,
             rulename=paste("\"", smsDF[i, "rulename" ], "\"", sep=""),
             ruledate=paste("\"", ruledate, "\"", sep=""),
             msgtxt=paste("\"", smsDF[i, "rulemsg" ], "\"", sep="")
    )
    
    # Create msg for this programid and userid
    postMsg(rooturl, msg)
  }
  
}


