# Batch control script
Sys.setenv(NOAWT = "true")

library("lattice")
library("MASS")
library(ggplot2)
library(rjson)
library("RMySQL")

rootdir <<- "/Users/stefanopicozzi/websites/nudge/R/fitbit/user"
imagesdir <<- "/Users/stefanopicozzi/websites/nudge/php/images"
setwd(rootdir)
programid <<- "6"
ppi <<- 300
# polllist <<- c('gas11', 'gas12', 'gas21', 'gas22')
polllist <<- c('gas11')

db <<- 1
con <<- dbConnect(dbDriver("MySQL"), host = "127.0.0.1", port=3307, dbname = "nudge", user = "admin6nZaW9E", password = "mJbS__JPs_mt")
#db <<- 0
#con <- dbConnect(dbDriver("MySQL"), host = "127.0.0.1", port=3306, dbname = "nudge", user = "root", password = "")
Sys.sleep(2)

sqlStmt <- paste(
   " SELECT u.userid, u.username, u.pushoveruser, u.fitbitkey, u.fitbitsecret, u.fitbitappname ",
   "  FROM user u, programuser pu",
   "  WHERE u.userid = pu.userid",
   "  AND   pu.roletype = 'participant'",
   "  AND  pu.programid = ", programid, sep = "")
userListDF <- dbGetQuery(con, sqlStmt)

for (i in 1:nrow(userListDF)) {
   print(userListDF[i,])
   
   userid <<- userListDF[i,'userid']
   username <<- userListDF[i,'username']
   user <<- userListDF[i,'username']
   key <<- userListDF[i,'fitbitkey']
   secret <<- userListDF[i,'fitbitsecret']
   appname <<- userListDF[i,'fitbitappname']
   pushoveruser = userListDF[i,'pushoveruser']

#   if ( username != "stefano" ) { next }
   
 for (pollname in polllist) {

    if ( pollname != "gas11" ) { next }
    
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
      
   dir.create(file.path(paste(imagesdir, "/POGO-8056/user/", sep=""), user), showWarnings = FALSE)
   filenamebp = paste(imagesdir, "/POGO-8056/user/", user, "/gas11bp.png", sep = "")
   filenamexy = paste(imagesdir, "/POGO-8056/user/", user, "/gas11xy.png", sep = "")
   
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
}

dbDisconnect(con)
system("cd ~/websites/nudge; git add php/images -A; git commit -m 'X'; git push")

