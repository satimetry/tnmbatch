# Send notification msg to database

library(rjson)
library("RMySQL")

dbListTables(con)

load(paste(user, "/userOptionsDF.dat", sep = ""))
smsDF <- cbind(userOptionsDF, smstxt = userOptionsDF$rulename)
smsDF <- data.frame(lapply(smsDF, as.character), stringsAsFactors = FALSE)
stepDateTime <- as.POSIXct(smsDF$ruledate, format = "%a %b %d %H:%M:%S EST %Y")
#stepDateTime <- as.POSIXct(smsDF$ruledate, format = "%Y-%m-%d")
smsDF <-cbind(smsDF, stepDateTime = stepDateTime)

today <- Sys.Date()
print(today)
for (i in 1:nrow(smsDF)) {
   dateTime <- smsDF[i, "stepDateTime"]
   diff <- as.numeric(difftime(today, dateTime, tz = "EST", units = c("days")))
   if ( diff > 1 ) {
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
      msgtxt, "); ", 
      sep = "")
   
   print(sqlStmt)
   result <- dbGetQuery(con, sqlStmt)
   Sys.sleep(2)
   result <- dbGetQuery(con, "COMMIT;")
}
