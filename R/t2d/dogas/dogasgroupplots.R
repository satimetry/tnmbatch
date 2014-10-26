#!/usr/bin/Rscript

# Batch control script
Sys.setenv(NOAWT = "true")

library("lattice")
library("MASS")
library(ggplot2)
library(rjson)
library(plyr)
library(scales)
library(reshape2)
        
#rooturl <<- "http://localhost:8080/tnm/rest"
rooturl <<- "http://nudgeserver-spicozzi.rhcloud.com/tnm/rest"
rootdir <<- "~/tnm/tnmbatch/R/t2d/dogas"
imagesdir <<- "~/websites/nudge/images"
setwd(rootdir)
ppi <<- 300

source("../../common/common.R")

# Do programid = 2 and gas observations
programid <- 2
obsname <- "gas11"

# Get programusers enrolled for this programid
programusers <- getProgramuser(rooturl, programid)

polldesc <- obsname
dir.create(file.path( paste(imagesdir, "/t2d/group/", sep="") ), showWarnings = FALSE)

userobsDF <- c()
for (programuser in programusers) {
   if (programuser$roletype != "participant") { next }
   userid <- programuser["userid"]
   userobstmpDF <- getUserobsDF(rooturl, programid, userid, obsname)   
   userobsDF <- rbind(userobsDF, userobstmpDF)
}

userobsDF <- as.data.frame(userobsDF)
userobsDF2 <- as.data.frame(userobsDF)

userobsDF <- ddply(userobsDF, c("username"), obsdate = substr(obsdate, 1, 10), summarise, obsvalue = obsvalue)
userobsDF[, "obsvalue"] <- as.numeric(userobsDF[, "obsvalue"])

regObsvalue <- lm(userobsDF$obsvalue ~ userobsDF$obsdate)

filenamexy = paste(imagesdir, "/t2d/group/", obsname, "xy.png", sep = "")
png(filenamexy,
    res = 72,
    width = 500,
    height = 300,
    units = "px")

ggplot(userobsDF, aes(x = factor(obsdate), y = obsvalue, colour = username, group = username)) + geom_line() + 
   theme(axis.text.x = element_text(angle = 45, hjust = 1) ) + 
   geom_point( size = 2, shape = 21) 

dev.off()

filenamexy = paste(imagesdir, "/t2d/group/", obsname, "facet.png", sep = "")
png(filenamexy,
    res = 72,
    width = 500,
    height = 300,
    units = "px")

ggplot(userobsDF, aes(x = factor(obsdate), y = obsvalue, colour = username, group = username) ) + geom_line() + 
   geom_point( size = 2, shape = 21) +
   theme(axis.text.x = element_text(angle = 45, hjust = 1) ) +
   facet_grid( username ~ .)

dev.off()

filenamexy = paste(imagesdir, "/t2d/group/", obsname, "heat.png", sep = "")
png(filenamexy,
    res = 72,
    width = 500,
    height = 300,
    units = "px")

userobsDF <- ddply(userobsDF, .(obsdate), transform, rescale = rescale(obsvalue))

ggplot(userobsDF, aes(x = factor(obsdate), y = username)) + 
   geom_tile(aes(fill = rescale), colour =   "white") + 
   scale_fill_gradient(low = "red", high = "green") +
   theme(axis.text.x = element_text(angle = 45, hjust = 1) )
   
dev.off()

filenamexy = paste(imagesdir, "/t2d/group/", obsname, "barplot.png", sep = "")
png(filenamexy,
    res = 72,
    width = 500,
    height = 800,
    units = "px")

#userobsDF <- ddply(userobsDF2, .(obsdate), transform, obsvalue=obsvalue()

#ggplot(userobsDF2, aes(obsdate, fill=as.factor(obsvalue))) + 
#   geom_bar(position="dodge",stat="identity")+
#   facet_wrap(~username, nrow=3)

ggplot(userobsDF2, aes(x=obsvalue)) + 
   geom_bar(aes(y=(..count..)/sum(..count..)), binwidth=4, fill="white", colour="black") + 
#   geom_histogram(fill="white", colour="black") +
   scale_y_continuous(labels=percent) +
   scale_x_discrete(breaks=c(-2, -1, 0, 1, 2), labels=c("Worst \nExpected", "Less Than \nExpected", "Expected", "More Than \nExpected", "Best \nExpected")) +
   theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
   facet_wrap(~username, nrow=3)
#   facet_grid(username ~ .)

dev.off()


