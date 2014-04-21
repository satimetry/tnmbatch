# Pull down observations and apply all rules
Sys.setenv(NOAWT = "true")

library(httr)
library(rjson)
library(RColorBrewer)
library("Rdrools6")
ls("package:Rdrools6", all = TRUE)
lsf.str("package:Rdrools6", all = TRUE)

# Sourced from fitbit app detail
token_url = "http://api.fitbit.com/oauth/request_token"
access_url = "http://api.fitbit.com/oauth/access_token"
auth_url = "http://www.fitbit.com/oauth/authorize"

# Sourced from fitbit app detail
fbr = oauth_app(appname, key, secret)
fitbit = oauth_endpoint(token_url, auth_url, access_url)
#token = oauth1.0_token(fitbit,fbr)
#sig = sign_oauth1.0(fbr, token=token$oauth_token, token_secret=token$oauth_token_secret)

#save(token, file = paste(user, "/fitbit-token.RData", sep = ""))
#save(sig, file = paste(user, "/fitbit-sig.RData", sep = ""))

load(file = paste(user, "/fitbit-token.RData", sep = ""), .GlobalEnv)
load(file = paste(user, "/fitbit-sig.RData", sep = ""), .GlobalEnv)

getURL <- "http://api.fitbit.com/1/user/-/activities/steps/date/"
startdate <- Sys.Date() - 7
startdatestr <- as.POSIXct(startdate, format = "%a %b %d")
getURL <- paste(getURL, startdate, "/today.json", sep = "")

# get all step data from my first day of use to the current date:
stepsJSON <- tryCatch({
   GET(getURL, sig)
}, warning = function(w) {
   print("Warning")
   stop()
}, error = function(e) {
   print("Error")
   stop()
}, finally = {
})

stepsDF <- NULL
for (i in 1:length(content(stepsJSON)$`activities-steps`)) {
   x = c( content(stepsJSON)$`activities-steps`[i][[1]][['dateTime']], content(stepsJSON)$`activities-steps`[i][[1]][['value']] ) 
   stepsDF <- cbind(stepsDF, x)
}
stepsDF <- t(stepsDF)
colnames(stepsDF) = c("stepDate", "stepCount")
stepsDF = as.data.frame(stepsDF, row.names = 1)

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
barplot(steps, ylim = c(0, max(steps)*1.2), col = cols, ylab = "Steps", names = gsub("2013-","", stepsDF[['stepDate']]), las=2, border = 0, cex.axis = 0.8)
abline(h = 10000, lty = 2)

dev.off()

Sys.setenv(NOAWT = "true")
inputDF <- cbind( id = c(user), stepsDF)
input.columns <- colnames(inputDF)
output.columns <-c ("id", "rulename", "ruledate", "rulemsg", "ruledata")

# Consider multiple rules files, so can separate user rule profiles from rules to be executed
# That is what rules does User want to fire and then apply rules
# User profile captured as rules
rules <- readLines("fitbit1.drl")
mode <- "STREAM"
rules.session <- rulesSession(mode, rules, input.columns, output.columns)
outputDF <- runRules(rules.session, inputDF)

save(outputDF, file = paste(user, "/outputDF.dat", sep = "") )



