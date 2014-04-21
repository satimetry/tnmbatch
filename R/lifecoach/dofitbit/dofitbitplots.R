# Pull down observations from database and do plots
Sys.setenv(NOAWT = "true")

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

bp = barplot(obsvalues, ylim = c(0, max(obsvalues)*1.2), col=cols, axes = FALSE, axisnames = FALSE)
axis(1, at = bp, 
     labels = c(substr(userobsDF[, "obsdate"], 6,10)),   
     tick = FALSE,
     las = 2,
     line = -0.5,
     cex.axis=0.4)
axis(2, cex.axis=0.8)
abline(h = 10000, lty = 2)

dev.off()

