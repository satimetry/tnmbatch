# Remove opt-out notifications

library("RMySQL")

dbListTables(con)

sqlStmt <- paste(
      " SELECT r.rulename FROM programruleuser pru, rule r",
      " WHERE pru.userid = 7 AND pru.programid = 1",
      " AND  pru.ruleid = r.ruleid", 
      " AND  pru.rulevalue = 1", sep = "")

optionsListDF <- dbGetQuery(con, sqlStmt)
Sys.sleep(2)

optionsListDF <- optionsListDF[order(optionsListDF$rulename),]

load(paste(user, "/outputDF.dat", sep = ""))
outputDF <- data.frame(lapply(outputDF, as.character), stringsAsFactors=FALSE)
outputDF <- outputDF[order(outputDF$rulename),]

userOptionsDF <- subset(outputDF, rulename %in% optionsListDF )

save(userOptionsDF, file = paste(user, "/userOptionsDF.dat", sep = ""))

