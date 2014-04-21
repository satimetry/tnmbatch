# Pull down observations from database and do plots
Sys.setenv(NOAWT = "true")

library(httr)
library(rjson)
library(RColorBrewer)

#db <<- 1
#con <<- dbConnect(dbDriver("MySQL"), host = "127.0.0.1", port=3307, dbname = "nudge", user = "admin6nZaW9E", password = "mJbS__JPs_mt")
#programid <- 5
#userid <- 7
#user <- "stefano" 

sqlStmt <- paste(
   " SELECT obsdate, obsvalue ",
   "  FROM userobs",
   "  WHERE obsname = 'activity'",
   "   AND  programid = ", programid,
   "   AND  userid = ", userid, 
   "  ORDER BY obsdate", sep = "")
obsDF <- dbGetQuery(con, sqlStmt)

colnames(obsDF) = c("obsdate", "obsvalue")

# extract step counts and convert to numeric:
obsvalues = as.numeric(as.character(obsDF$obsvalue))

fileName = paste(imagesdir, "/lifecoach/user/", user, "/activity.png", sep = "")
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
     labels = c(substr(obsDF[['obsdate']], 6,10)),   
     tick = FALSE,
     las = 2,
     line = -0.5,
     cex.axis=0.6)
axis(2, cex.axis=0.8)
abline(h = 10000, lty = 2)

dev.off()

#dbDisconnect(con)

