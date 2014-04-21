# Remove opt-out notifications

rootdir <- "/Users/stefanopicozzi/websites/nudge"
user <- "stefano"
ppi <- 300
userid <- "7"
programid <- "1"

wd <- paste(rootdir, "/R/fitbit/user/", user, sep="")
setwd(wd)

library("RMySQL")

#con <- dbConnect(dbDriver("MySQL"), host = "127.0.0.1", dbname = "nudge", user = "root", password = "")

dbListTables(con)

sqlStmt <- paste(
      " SELECT r.rulename FROM programruleuser pru, rule r",
      " WHERE pru.userid = 7 AND pru.programid = 1",
      " AND  pru.ruleid = r.ruleid", 
      " AND  pru.rulevalue = 1", sep = "")

optionsListDF <- dbGetQuery(con, sqlStmt)
Sys.sleep(2)

optionsListDF <- optionsListDF[order(optionsListDF$rulename),]

#dbDisconnect(con)

load("outputDF.dat")
outputDF <- data.frame(lapply(outputDF, as.character), stringsAsFactors=FALSE)
outputDF <- outputDF[order(outputDF$rulename),]

userOptionsDF <- subset(outputDF, rulename %in% optionsListDF )

save(userOptionsDF, file = "userOptionsDF.dat")

