# Pull down observations from database and do plots
Sys.setenv(NOAWT = "true")

# Default test case
if ( !exists("userid") ) { userid <- 7 }
if ( !exists("programid") ) { programid <- 1 }
if ( !exists("obsname") ) { obsname <- "weight" }

rooturl <- "https://nudgeserver-spicozzi.rhcloud.com/tnm/rest"
rootdir <- "~/TheNudgeMachine/GitHub/tnmbatch/R/lifecoach/dowithings"
imagesdir <- "~/TheNudgeMachine/OpenShift/nudge/images"
ppi <- 300
source("../common/common.R")

library(RColorBrewer)

# Get user details for userid
user <- getUser(rooturl, userid)
username <<- user['username']

userobsDF <- NULL
# Get observations for this programid and userid and obsname
userobsDF <- getUserobsDF(rooturl, programid, userid, obsname)
if ( is.null(userobsDF) ) { stop("userobsDF is NULL") }
if ( nrow(userobsDF) == 0 ) { stop("userobsDF is empty") }

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
     type = "o",
     lty = 1,
     cex = 0.5,
     pch = 20,
     axes = FALSE,
     ylab = obsname,
     ylim = c( floor(min(obsvalues)), ceiling(max(obsvalues)) ),
     xlim = c( min(obsdate), max(obsdate) ),
     xlab = "Date",
     col = "deepskyblue1",
     cex.lab = 0.8,
     main = paste(obsname, " Plot", split = ""))

axis(2, at = seq( floor(min(obsvalues)), ceiling(max(obsvalues)), 0.50),
   las = 1,
   cex.axis=0.5)

axis(1, at = obsdate, 
   labels = substr(obsdate, 1, 10), 
   cex.axis = 0.2, las = 2)

if (obsname == "bmi") {
   axis(2, at = seq( floor(min(obsvalues)), ceiling(max(obsvalues)), 0.25),
        las = 1,
        cex.axis=0.5)
   abline(h = 27.5, lty = 2)   
}
if (obsname == "weight") {   
   abline(h = 80, lty = 2)
}

dev.off()

