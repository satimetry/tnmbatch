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

fileName = paste(imagesdir, "/lifecoach/user/", username, "/", obsname, ".png", sep = "")
png(paste(fileName, sep=""),
    res = ppi,
    width = 5*ppi,
    height = 4*ppi,
    pointsize = 10,
    units = "px")

if (obsname == "bmi") {
   # set up and plot the graph:
   brew = brewer.pal(6,"Set1") # red, blue, green
   cols = rep(brew[1],length(obsvalues))
   cols[obsvalues >= 30] = brew[1]
   cols[obsvalues < 30 && obsvalues > 29] = brew[6]
   cols[obsvalues <= 29] = brew[3]

   bp = barplot(obsvalues, ylim = c(0, max(obsvalues)*1.2), col=cols, axes = FALSE, axisnames = FALSE)
   axis(1, at = bp, 
     labels = c(substr(userobsDF[, "obsdate"], 6,10)),   
     tick = FALSE,
     las = 2,
     line = -0.5,
     cex.axis=0.4)
   axis(2, at = seq(0, 40, 1),
     cex.axis=0.4)
   abline(h = 29, lty = 2)
   abline(h = 30, lty = 1)
}

if (obsname == "weight") {
   # set up and plot the graph:
   brew = brewer.pal(6,"Set1") # red, blue, green
   cols = rep(brew[1],length(obsvalues))
   cols[obsvalues >= 84] = brew[1]
   cols[obsvalues < 84 && obsvalues > 83] = brew[6]
   cols[obsvalues <= 83] = brew[3]
   
   bp = barplot(obsvalues, ylim = c(0, max(obsvalues)*1.2), col=cols, axes = FALSE, axisnames = FALSE)
   axis(1, at = bp, 
        labels = c(substr(userobsDF[, "obsdate"], 6,10)),   
        tick = FALSE,
        las = 2,
        line = -0.5,
        cex.axis=0.4)
   axis(2, at = seq(0, 90, 1),
        cex.axis=0.4)
   abline(h = 83, lty = 2)
   abline(h = 84, lty = 1)
}

dev.off()

