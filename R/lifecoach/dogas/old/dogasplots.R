# Batch control script
Sys.setenv(NOAWT = "true")

library("lattice")
library("MASS")
library(ggplot2)
library(rjson)
library("RMySQL")

polllist <<- c('gas11', 'gas12', 'gas21', 'gas22')
#polllist <<- c('gas11')
   
for (pollname in polllist) {
    
  sqlStmt <- paste(
    " SELECT pu.q01value AS x, p.polldesc AS polldesc, pu.polldate AS polldate",
    " FROM programpolluser pu,",
    "      poll p",
    " WHERE pu.programid = p.programid",
    "  AND  p.pollid = pu.pollid",
    "  AND  p.pollname = '", pollname, "'",
    "  AND  p.programid = ", programid,
    "  AND  pu.userid = ", userid,
    " ORDER BY polldate ASC",
    sep = "")
   
  x <- c()
  gasDF <- dbGetQuery(con, sqlStmt)
  for (i in 1:nrow(gasDF)) {
    x <- append(x, gasDF[i, 'x'])   
  }
  
  if (length(x) < 1) { next }
  polldesc <- gasDF[1,'polldesc']
      
  dir.create(file.path(paste(imagesdir, "/lifecoach/user/", sep=""), user), showWarnings = FALSE)
  filenamebp = paste(imagesdir, "/lifecoach/user/", user, "/", pollname, "bp.png", sep = "")
  filenamexy = paste(imagesdir, "/lifecoach/user/", user, "/", pollname, "xy.png", sep = "")
   
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

  gasDF$polldate <- as.POSIXct(gasDF$polldate, format = "%Y-%m-%d %H:%M:%S")
#   x3 <- lm(gasDF$x ~ poly(gasDF$polldate,3) )
  x1 <- lm(gasDF$x ~ gasDF$polldate)
   
  png(filenamexy,
    res = 72,
    width = 500,
    height = 300,
    units = "px")
   
  plot(gasDF$polldate, gasDF$x,
    type = "b",
    axes = FALSE,
    ylab = "Response",
    ylim = c(-2, 2),
    xlim = c(min(gasDF$polldate), max(gasDF$polldate)),
    xlab = "Date",
    col = "deepskyblue1",
    main = polldesc )
   
#   abline(x1, lwd = 2, col = "orangered")
#   lines(predict(x3, newdata = data.frame(gasDF$polldate)), lwd = 3, col="gray48" )
  axis(2, at = seq(-2, 2, by = 1), 
    labels = c("Worst \nExpected", "Less Than \nExpected", "Expected", "More Than \nExpected", "Best \nExpected"),
    cex.axis = 0.5, las = 2)
  axis(1, at = gasDF$polldate, labels = substr(gasDF$polldate, 6, 10), cex.axis = 0.8, las = 2)
#   text(loc[1], loc[4], "Daily PQM Score", pos = 3, xpd = T)

  grid()
#    polygon(c( min(gasDF$polldate), min(gasDF$polldate):max(gasDF$polldate), max(gasDF$polldate) ), c(0, gasDF$x, 0), col = "deepskyblue1", border = NA)
    
  loc <- par("usr")
  box()
  dev.off()   
   
}

