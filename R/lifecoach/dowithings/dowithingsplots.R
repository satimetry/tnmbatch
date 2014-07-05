# Pull down observations from database and do plots
Sys.setenv(NOAWT = "true")

library(RColorBrewer)

# Get user details for userid
user <- getUser(rooturl, userid)
username <<- user['username']

# Get observations for this programid and userid and obsname
userobsDF <- getUserobsDF(rooturl, programid, userid, obsname)

# extract step counts and convert to numeric:
obsvalues = as.numeric( as.character(userobsDF[, "obsvalue"]) )
obsdate <- as.POSIXct(userobsDF[, "obsdate"], format = "%Y-%m-%d %H:%M:%S")

fileName = paste(imagesdir, "/lifecoach/user/", username, "/", obsname, ".png", sep = "")
png(paste(fileName, sep=""),
    res = ppi,
    width = 5*ppi,
    height = 4*ppi,
    pointsize = 10,
    units = "px")

plot(obsdate, obsvalues,
     type = "b",
     axes = FALSE,
     ylab = obsname,
     ylim = c( floor(min(obsvalues)), ceiling(max(obsvalues)) ),
     xlim = c( min(obsdate), max(obsdate) ),
     xlab = "Date",
     col = "deepskyblue1",
     main = paste(obsname, " Plot", split = ""))

axis(2, at = seq( floor(min(obsvalues)), ceiling(max(obsvalues)), 0.25),
   las = 1,
   cex.axis=0.6)

axis(1, at = obsdate, 
   labels = substr(obsdate, 6, 10), 
   cex.axis = 0.8, las = 2)

if (obsname == "bmi") {
   abline(h = 29, lty = 2)   
}
if (obsname == "weight") {   
   abline(h = 83, lty = 2)
}

dev.off()

