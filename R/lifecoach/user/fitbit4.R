# Send notification

library(rjson)

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
   msg <- paste(smsDF[i, "rulemsg" ], ". To opt-out from this nudge visit: ", "http://www.thenudgemachine.com", sep = "") 
   
   curl_cmd = paste(
      "curl -s",
      " -F \"token=acqa2Xgn6Fj7NsctUaxqPm8ngURksP\" ",
      " -F \"user=", pushoverkey, "\" ",
      " -F \"message=", msg, "\" ",
      " https://api.pushover.net/1/messages.json", 
      sep = "")
   
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

