# Pull down observations from databse and do plots
Sys.setenv(NOAWT = "true")

library(httr)
library(rjson)
library(RColorBrewer)

sqlStmt <- paste(
   " SELECT obsdate, obsvalue ",
   "  FROM userobs",
   "  WHERE obsname = 'activity'",
   "   AND  programid = ", programid,
   "   AND  userid = ", userid, 
   "  ORDER BY obsdate", sep = "")
stepsDF <- dbGetQuery(con, sqlStmt)

colnames(stepsDF) = c("stepDate", "stepCount")

# extract step counts and convert to numeric:
steps = as.numeric(as.character(stepsDF$stepCount))

fileName = paste(imagesdir, "/fitbit/user/", user, "/activity.png", sep = "")
png(paste(fileName, sep=""),
    res = ppi,
    width = 5*ppi,
    height = 4*ppi,
    pointsize = 10,
    units = "px")

# set up and plot the graph:
brew = brewer.pal(3,"Set1") # red, blue, green
cols = rep(brew[1],length(steps))
cols[steps > 10000] = brew[3]
#barplot(steps, ylim = c(0, max(steps)*1.2), col = cols, ylab = "Steps", names = gsub("2013-","", stepsDF[['stepDate']]), las=2, border = 0, cex.axis = 0.8)

bp = barplot(steps, ylim = c(0, max(steps)*1.2), col=cols, axes = FALSE, axisnames = FALSE)
text(bp, labels = c(substr(stepsDF[['stepDate']], 1,10)), ylab="Steps", srt = 45, adj = c(1.1,1.1), xpd = TRUE, cex=1.0)
axis(2)
abline(h = 10000, lty = 2)

dev.off()

