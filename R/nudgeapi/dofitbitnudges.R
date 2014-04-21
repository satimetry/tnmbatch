# Pull down observations and apply all rules
Sys.setenv(NOAWT = "true")

library(httr)
library(rjson)
library("RMySQL")
library("Rdrools6")
ls("package:Rdrools6", all = TRUE)
lsf.str("package:Rdrools6", all = TRUE)

sqlStmt <- paste(
   " SELECT obsdate, obsvalue ",
   "  FROM userobs",
   "  WHERE obsname = 'activity'",
   "   AND  programid = ", programid,
   "   AND  userid = ", userid, 
   "  ORDER BY obsdate", sep = "")

obsDF <- c()
obsDF <- dbGetQuery(con, sqlStmt)

colnames(obsDF) = c("obsdate", "obsvalue")

inputDF <- cbind( id = c(user), obsDF)
input.columns <- colnames(inputDF)
output.columns <-c ("id", "rulename", "ruledate", "rulemsg", "ruledata")

# Consider multiple rules files, so can separate user rule profiles from rules to be executed
# That is what rules does User want to fire and then apply rules
# User profile captured as rules
rules <- readLines("dofitbit.drl")
mode <- "STREAM"
rules.session <- rulesSession(mode, rules, input.columns, output.columns)
outputDF <- runRules(rules.session, inputDF)

# Apply opt-outs

sqlStmt <- paste(
   " SELECT r.rulename FROM programruleuser pru, rule r",
   " WHERE pru.userid = ", userid, 
   " AND pru.programid = ", programid,
   " AND  pru.ruleid = r.ruleid",
   " AND  r.rulename != 'ruleManual'",
   " AND  pru.rulevalue = 1", sep = "")

optionsListDF <- dbGetQuery(con, sqlStmt)
Sys.sleep(2)

optionsListDF <- optionsListDF[order(optionsListDF$rulename),]

#load(paste(user, "/outputDF.dat", sep = ""))
outputDF <- data.frame(lapply(outputDF, as.character), stringsAsFactors=FALSE)
outputDF <- outputDF[order(outputDF$rulename),]

userOptionsDF <- subset(outputDF, rulename %in% optionsListDF )

save(userOptionsDF, file = paste("../user/", user, "/userOptionsDF.dat", sep = ""))

smsDF <- cbind(userOptionsDF, smstxt = userOptionsDF$rulename)
smsDF <- data.frame(lapply(smsDF, as.character), stringsAsFactors = FALSE)
stepDateTime <- as.POSIXct(smsDF$ruledate, format = "%a %b %d %H:%M:%S EST %Y")
#stepDateTime <- as.POSIXct(smsDF$ruledate, format = "%Y-%m-%d")
smsDF <-cbind(smsDF, stepDateTime = stepDateTime)

today <- Sys.Date()
print(today)

if (nrow(smsDF) > 0) {
  for (i in 1:nrow(smsDF)) {
   dateTime <- smsDF[i, "stepDateTime"]
   diff <- as.numeric(difftime(today, dateTime, tz = "EST", units = c("days")))
   if ( diff > 2 ) {
      next
   }
   
   print(smsDF[i, "smstxt" ])  
   
   username <- smsDF[i, "username"]
   rulename <- paste("'", smsDF[i, "rulename" ], "'", sep="")
   ruledate <- paste("'", smsDF[i, "stepDateTime" ], "'", sep="")
   msgtxt <- paste("'", smsDF[i, "rulemsg" ], "'", sep="")
   
   sqlStmt <- paste(
      " INSERT INTO msg (programid, userid, rulename, ruledate, msgtxt)",
      "  VALUES (", 
      programid, ", ",
      userid, ", ",
      rulename, ", ",
      ruledate, ", ",
      msgtxt, " ",
      "); ", 
      sep = "")
   
   print(sqlStmt)
   result <- dbGetQuery(con, sqlStmt)
   Sys.sleep(1)
   result <- dbGetQuery(con, "COMMIT;")
 }
}

