# Batch control script
Sys.setenv(NOAWT = "true")

library("lattice")
library("MASS")
library(ggplot2)
library(rjson)

# Get observations for this programid and userid
userobsDF <- getUserobsDF(rooturl, programid, userid, obsname)
userobss <- getUserobs(rooturl, programid, userid, obsname)
user <- getUser(rooturl, userid)
username <- user['username']

x <- c()
for (i in 1:nrow(userobsDF)) {
  x <- append(x, userobsDF[i, 'obsvalue'])   
}
  
if (length(x) > 0) {
  polldesc <- obsname
      
  dir.create(file.path( paste(imagesdir, "/lifecoach/user/", username, sep="") ), showWarnings = FALSE)
  filenamebp = paste(imagesdir, "/lifecoach/user/", username, "/", obsname, "bp.png", sep = "")
  filenamexy = paste(imagesdir, "/lifecoach/user/", username, "/", obsname, "xy.png", sep = "")
   
  # GAS Bar Plot
  png(filenamebp,
    res = 72,
    width = ppi,
    height = ppi,
    units = "px")

  ylim <- c(0, 100)
  xpct <- ( table(x)/sum(table(x)) ) * 100
   
  bp <- barplot(xpct,
    xaxt = "n",
    ylab = "Percentage",
    ylim = ylim,
    xlab = "Goal Attainment Scale Outcome",
    col = "deepskyblue1",
    main = polldesc,
    cex.lab = 0.9)
    text(x = bp, y = xpct, label = table(x), pos = 3, cex = 0.8, col = "red")

  xunique <- unique(unlist(x, use.names = FALSE))
  if (length(xunique) == 5) {
    axis(1, at = bp, 
      labels = c("Worst \nExpected", "Less Than \nExpected", "Expected", "More Than \nExpected", "Best \nExpected"),   
      tick = FALSE,
      las = 2,
      line = -0.5,
      cex.axis=0.6)
   } else {
    axis(1, at = bp,
    labels = unique(x),
    tick = FALSE,
    las = 2,
    line = -0.5,
    cex.axis=0.6)
  }
  axis(2, at = seq(0, 100, by = 10))

  dev.off()

  obsdate <- as.POSIXct(userobsDF[, "obsdate"], format = "%Y-%m-%d %H:%M:%S")
  obsvalue <- userobsDF[, "obsvalue"]
  
#   x3 <- lm(userobsDF$x ~ poly(userobsDF$polldate,3) )
  x1 <- lm(obsvalue ~ obsdate)
   
  png(filenamexy,
    res = 72,
    width = 500,
    height = 300,
    units = "px")
   
  plot(obsdate, obsvalue,
    type = "b",
    axes = FALSE,
    ylab = "Response",
    ylim = c(-2, 2),
    xlim = c( min(obsdate), max(obsdate) ),
    xlab = "Date",
    col = "deepskyblue1",
    main = polldesc )
   
#   abline(x1, lwd = 2, col = "orangered")
#   lines(predict(x3, newdata = data.frame(userobsDF$obsdate)), lwd = 3, col="gray48" )
  axis(2, at = seq(-2, 2, by = 1), 
    labels = c("Worst \nExpected", "Less Than \nExpected", "Expected", "More Than \nExpected", "Best \nExpected"),
    cex.axis = 0.5, las = 2)
  axis(1, at = obsdate, labels = substr(obsdate, 6, 10), cex.axis = 0.8, las = 2)
#   text(loc[1], loc[4], "Daily PQM Score", pos = 3, xpd = T)

  grid()
#    polygon(c( min(userobsDF$polldate), min(userobsDF$polldate):max(userobsDF$polldate), max(userobsDF$polldate) ), c(0, userobsDF$x, 0), col = "deepskyblue1", border = NA)
    
  loc <- par("usr")
  box()
  dev.off()   

}

