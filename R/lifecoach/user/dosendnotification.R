# Send notification

library(rjson)

today <- Sys.Date()
#todaystr <- as.POSIXct(today, format = "%Y-%m-%d")
sqlStmt <- paste(
   " SELECT m.msgid, u.username, m.rulename, m.msgdate, m.msgtxt ",
   "  FROM user u, msg m, programuser pu",
   "  WHERE pu.userid = m.userid",
   "  AND   u.userid = m.userid",   
   "  AND   u.userid = ", userid,
   "  AND   pu.programid = ", programid,
   "  AND   m.issent = 0",
   "  AND   pu.programid = m.programid", sep = "")

msgdf <- c()
msgDF <- dbGetQuery(con, sqlStmt)

if (nrow(msgDF) > 0) {

pushDF <- c()
pushDF <- cbind(msgDF, smstxt = msgDF$rulename)
pushDF <- data.frame(lapply(msgDF, as.character), stringsAsFactors = FALSE)
stepDateTime <- as.POSIXct(msgDF$msgdate, format = "%Y-%m-%d %H:%M:%S")
#stepDateTime <- as.POSIXct(smsDF$ruledate, format = "%Y-%m-%d")
pushDF <-cbind(msgDF, stepDateTime = stepDateTime)

today <- Sys.Date()
print(today)
for (i in 1:nrow(pushDF)) {
   dateTime <- pushDF[i, "stepDateTime"]
   diff <- as.numeric(difftime(today, dateTime, tz = "EST", units = c("days")))
   if ( diff > 1 ) {
      print(diff);
#      next
   }
   
   msg <- paste(pushDF[i, "msgtxt" ], ". To opt-out from nudges visit: ", "http://www.thenudgemachine.com/rulesettings.php", sep = "") 
   
   print(msg)

   curl_cmd = paste(
      "curl -s",
      " -F \"token=acqa2Xgn6Fj7NsctUaxqPm8ngURksP\" ",
      " -F \"user=", pushoveruser, "\" ",
      " -F \"message=", msg, "\" ",
      " https://api.pushover.net/1/messages.json", 
      sep = "")
   
   msgid <- pushDF[i, "msgid"]
   sqlStmt <- paste(" UPDATE msg SET issent = 1 WHERE msgid = ", msgid, ";", sep = "")
   print(sqlStmt)
   sqlresult <- dbGetQuery(con, sqlStmt)
   Sys.sleep(1)
   sqlresult <- dbGetQuery(con, "COMMIT;")
   
   result <- tryCatch({
      system(curl_cmd)
   }, warning = function(w) {
      print("Warning")
      stop()
   }, error = function(e) {
      print("Error")
      stop()
   }, finally = {
   })
}

}
