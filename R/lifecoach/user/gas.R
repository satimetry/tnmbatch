library("lattice")
library("MASS")
library(ggplot2)

rootdir <<- "/Users/stefanopicozzi/websites/nudge/R/fitbit/user"
imagesdir <<- "/Users/stefanopicozzi/websites/nudge/php/images"
setwd(rootdir)
programid <<- "1"
ppi <<- 300

user <- "stefano"
filename = paste(imagesdir, "/fitbit/user/", user, "/gas11.png", sep = "")
filename2 = paste(imagesdir, "/fitbit/user/", user, "/gas12.png", sep = "")

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

barplot(table(x), 
#   axes = FALSE,
   ylab = "Counts",
   xlab = "Goal Attainment Scale Outcome",
   col = "deepskyblue1",
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
