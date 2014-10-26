#!/usr/bin/Rscript

# Batch control script
#Sys.setenv(NOAWT = "true")

library("lattice")
library("MASS")
library(ggplot2)
library(rjson)
library(plyr)
library(scales)
library(rgl)

#rooturl <<- "http://localhost:8080/tnm/rest"
rooturl <<- "http://nudgeserver-spicozzi.rhcloud.com/tnm/rest"
rootdir <<- "~/tnm/tnmbatch/R/t2d/dogas"
imagesdir <<- "~/websites/nudge/images"
setwd(rootdir)
ppi <<- 300

source("../../common/common.R")

# Do programid = 2 and medicate observations
programid <- 2
obsname <- "medicate"

# Get programusers enrolled for this programid
programusers <- getProgramuser(rooturl, programid)

polldesc <- obsname
dir.create(file.path( paste(imagesdir, "/t2d/user/", sep="") ), showWarnings = FALSE)

Sys.sleep(2)
userobsDF <- c()
for (programuser in programusers) {
   if (programuser$roletype != "participant") { next }
   userid <- programuser["userid"]
   userobstmpDF <- getUserobsDF(rooturl, programid, userid, obsname)   

   obstime <- userobstmpDF[, "obsdate"]
   attr(obstime, "tzone") <- "Australia/Sydney"
   date <- as.character(strptime(obstime, "%Y-%m-%d"))   
   datetime <- paste(date, " 07:00:00", sep="")
   medtime <- as.POSIXct(datetime, format="%Y-%m-%d %H:%M:%S")   
   meddiff <- as.numeric(difftime(obstime, medtime)/60)
   userobstmpDF <- cbind(userobstmpDF, meddiff )
   userobsDF <- rbind(userobsDF, userobstmpDF)   
}

userobsDF <- as.data.frame(userobsDF)
userobsDF[, "obsvalue"] <- as.numeric(as.character(userobsDF[, "obsvalue"])) - 2
userobsDF[, "meddiff"] <- as.numeric(as.character(userobsDF[, "meddiff"]))
userobsDF <- ddply(userobsDF, c("username"), obsdate=substr(obsdate, 1, 10), summarise, obsvalue=obsvalue, meddiff=meddiff)

filenamexy = paste(imagesdir, "/t2d/group/", "pillcount", "facet.png", sep = "")
png(filenamexy,
    res = 72,
    width = 500,
    height = 800,
    units = "px")

ggplot(userobsDF, aes(x = factor(obsdate), y = obsvalue, colour = username, group = username) ) + geom_line() + 
   geom_point( size = 2, shape = 21) +
   theme(axis.text.x = element_text(angle = 45, hjust = 1) ) +
   facet_grid( username ~ .) +
   geom_hline(yintercept=0) +
   geom_vline(xintercept=15)

dev.off()

filenamexy = paste(imagesdir, "/t2d/group/", "pilltime", "facet.png", sep = "")
png(filenamexy,
    res = 72,
    width = 500,
    height = 800,
    units = "px")

ggplot(userobsDF, aes(x = factor(obsdate), y = meddiff, colour = username, group = username) ) + geom_line() + 
   geom_point( size = 2, shape = 21) +
   theme(axis.text.x = element_text(angle = 45, hjust = 1) ) +
   facet_grid( username ~ .) +
   geom_hline(yintercept=0) +
   geom_vline(xintercept=15)
   
dev.off()

userobsDF[, "obsvalue"] <- as.factor(userobsDF[, "obsvalue"])

filenamexy = paste(imagesdir, "/t2d/group/", "pilldosage", "facet.png", sep = "")
png(filenamexy,
    res = 72,
    width = 500,
    height = 800,
    units = "px")

ggplot(userobsDF, aes(x = factor(obsdate), y = meddiff, colour = obsvalue, group = username) ) + 
   geom_line() +
   geom_point( size = 4, shape = 16) +
   theme(axis.text.x = element_text(angle = 45, hjust = 1) ) +
   facet_grid( username ~ .) +
   scale_colour_brewer(palette="Set1") +
   geom_hline(yintercept=0) +
   geom_hline(yintercept=60, linetype="dashed") +
   geom_hline(yintercept=-60, linetype="dashed") +
   geom_vline(xintercept=15)

dev.off()
