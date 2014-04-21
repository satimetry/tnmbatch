# Batch control script

rootdir <- "/Users/stefanopicozzi/websites/nudge"
user <- "stefano"
ppi <- 300
userid <- "7"
programid <- "1"

con <<- dbConnect(dbDriver("MySQL"), host = "127.0.0.1", port=3307, dbname = "nudge", user = "admin6nZaW9E", password = "mJbS__JPs_mt")
#con <- dbConnect(dbDriver("MySQL"), host = "127.0.0.1", port=3306, dbname = "nudge", user = "root", password = "")
Sys.sleep(2)

source("fitbit1.R")
source("fitbit3.R")
source("fitbit4.R")
source("fitbit5.R")
source("fitbit6.R")

dbDisconnect(con)

system("cd ~/websites/nudge; git add .; git commit -m 'X'; git push")
