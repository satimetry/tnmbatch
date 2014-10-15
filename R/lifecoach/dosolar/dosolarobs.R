# Pull down observations and insert into database

Sys.setenv(NOAWT = "true")
library(httr)
library(rjson)
library('RCurl')

# Get user details for userid
user <- getUser(rooturl, userid)
username <- user['username']

csvDF <- c()
inputsolarDF <- c()
listfiles <- list.files(path = ".", pattern = "Nudge-Monitor")
for (file in listfiles) {
   csvDF <- read.csv(file = file, header = FALSE, sep = ";", stringsAsFactors = FALSE)   
   csvDF <- csvDF[-1,]
   csvDF <- subset(csvDF, V2 != "n/a")
   csvDF <- csvDF[sample(nrow(csvDF), 30), ]
   inputsolarDF <- rbind(inputsolarDF, csvDF)
}

colnamesDF <- read.csv(file = "SolarHeaders.csv", header = FALSE, sep = ";", stringsAsFactors = FALSE)
solarnames <- c()
for (i in 1:ncol(colnamesDF)) {
   solarname <- colnamesDF[1,i]
   n <- regexpr(" ", solarname)
   if ( n > 0 ) {
      solarname <- substr(solarname, 1, n)
   }  
   solarnames <- cbind(solarnames, solarname)
}

solarDF <- inputsolarDF
colnames(solarDF) = solarnames
inputDF <- cbind( username = c(username), solarDF)
inputDF <- data.frame(lapply(inputDF, as.character), stringsAsFactors=FALSE)

# Remove the userobs for this programid and userid and obsname
delUserobs(rooturl, programid, userid, "solar")

for (i in 1:nrow(inputDF)) { 

   userobs <- c(
      programid=programid,
      userid,
      obsname="\"solar\"",
#      obsdate=paste("\"", inputDF[i, "Timestamp"], "\"", sep=""),
      obsdate=paste("\"", substr(inputDF[i, "Timestamp"], 1, 10), "\"", sep=""),      
      obsvalue=inputDF[i, "S."],
      obsdesc="\"System generated from solar filelogger\""                
      )
   
   postUserobs(rooturl, userobs)
   
}
