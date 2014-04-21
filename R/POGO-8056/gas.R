library("lattice")
library("MASS")
library(ggplot2)

rootdir <<- "/Users/stefanopicozzi/websites/nudge/R/fitbit/user"
imagesdir <<- "/Users/stefanopicozzi/websites/nudge/php/images"
setwd(rootdir)
programid <<- "1"
ppi <<- 300

user <- "stefano"
filename = paste(imagesdir, "/POGO-8056/user/", user, "/gas11-a.png", sep = "")
filename2 = paste(imagesdir, "/POGO-8056/user/", user, "/gas12.png", sep = "")
filename = paste(imagesdir, "/POGO-8056/user/", user, "/gas11.png", sep = "")

x <- c(-1, -2, 0, 1, 2, 1, -1, 1, 2, 0, 1, -2, -1, 2, 2)

# GAS Histogram
png(filename2,
    res = 72,
    width = ppi,
    height = ppi,
    units = "px")

gas <- x
h = hist(gas, breaks = c(-3, -2, -1, 0, 1, 2))
h$density = (h$counts/sum(h$counts)) * 100

plot(h,
     freq = FALSE,
     axes = FALSE,
     ylab = "Percentage",
     xlab = "Goal Attainment Scale Outcome",
     col = "deepskyblue1",
     main = "Lower Order Goal" )
axis(1, at = seq(-2, 2, by = 1), 
     labels = c("Worst \nExpected", "Less Than \nExpected", "Expected", "More Than \nExpected", "Best \nExpected"),
     cex=0.5)
axis(2, at = seq(0, 100, by = 10))
dev.off()



# GAS Histogram
png(filename,
    res = 72,
    width = ppi,
    height = ppi,
    units = "px")

qplot(factor(x),
#   axes = FALSE,
   ylab = "Counts",
   xlab = "Goal Attainment Scale Outcome",
   main = "Lower Order Goal")

#axis(1, at = seq(-2, 2, by = 1), 
#     labels = c("Worst \nExpected", "Less Than \nExpected", "Expected", "More Than \nExpected", "Best \nExpected"),
#     cex=0.5)
#axis(2, at = seq(0, 100, by = 1))
dev.off()


# GAS Histogram
png(filename,
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
   main = "Lower Order Goal",
   cex.lab = 0.9)
text(x = bp, y = xpct, label = table(x), pos = 3, cex = 0.8, col = "red")
axis(1, at = bp, 
   labels = c("Worst \nExpected", "Less Than \nExpected", "Expected", "More Than \nExpected", "Best \nExpected"),
   tick = FALSE,
   las = 2,
   line = -0.5,
   cex.axis=0.6)
axis(2, at = seq(0, 100, by = 10))

dev.off()

