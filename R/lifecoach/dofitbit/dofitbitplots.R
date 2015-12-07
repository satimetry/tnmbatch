#!/usr/local/bin/Rscript

# Batch control script
Sys.setenv(NOAWT = "true")

setwd("~/GitHub/tnmbatch/R/lifecoach")
source("../common/common.R")

library(RColorBrewer)

# Get user details for userid
user <- getUser(rooturl, userid)
username <<- user['username']

# Get observations for this programid and userid and obsbame
userobsDF <- getUserobsDF(rooturl, programid, userid, obsname)

# extract step counts and convert to numeric:
obsvalues = as.numeric( as.character(userobsDF[, "obsvalue"]) )

fileName = paste(imagesdir, "/lifecoach/user/", username, "/activity.png", sep = "")
png(paste(fileName, sep=""),
    res = ppi,
    width = 5*ppi,
    height = 4*ppi,
    pointsize = 10,
    units = "px")

# set up and plot the graph:
brew = brewer.pal(3,"Set1") # red, blue, green
cols = rep(brew[1],length(obsvalues))
cols[obsvalues > 10000] = brew[3]

bp = barplot(obsvalues, ylim = c(0, max(obsvalues)*1.2), col=cols, axes = FALSE, 
   xlab = "Date",
   ylab = "Steps")

axis(1, at = bp, 
     labels = c(substr(userobsDF[, "obsdate"], 6,10)),   
     tick = FALSE,
     las = 2,
     line = -0.5,
     cex.axis=0.6)

axis(2, at = seq(0, max(obsvalues)*1.2, 1000),
     las = 1,
     cex.axis=0.6)
abline(h = 10000, lty = 2)

dev.off()

