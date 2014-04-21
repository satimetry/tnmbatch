#!/usr/bin/Rscript

# Batch control script
Sys.setenv(NOAWT = "true")
library(rjson)
library("RMySQL")

rootdir <<- "/Users/stefanopicozzi/websites/nudge/R/lifecoach/dogas"
imagesdir <<- "/Users/stefanopicozzi/websites/nudge/php/images"
setwd(rootdir)
programid <<- "1"
ppi <<- 300

#system("rhc port-forward nudge", wait = FALSE)
#Sys.sleep(10)

db <<- 2
con <- dbConnect(dbDriver("MySQL"), host = "127.0.0.1", port=58026, dbname = "nudgeserver", user = "admin9QQDwEy", password = "HE74ZUiuJXWl")

#db <<- 1
#con <<- dbConnect(dbDriver("MySQL"), host = "127.0.0.1", port=3307, dbname = "pogo8056", user = "admindBQBjRs", password = "APvl_BNEIQer")
#db <<- 1
#con <<- dbConnect(dbDriver("MySQL"), host = "127.0.0.1", port=3307, dbname = "nudge", user = "admin6nZaW9E", password = "mJbS__JPs_mt")
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

#  if (username != 'stefano') { next }
   
  pollidlist <<- c(15, 16, 18)
  for (polliditem in pollidlist) {
    
    pollid <<- polliditem
    if ( pollid == 15 ) { gastype <<- "gas11" }
    if ( pollid == 16 ) { gastype <<- "gas12" }
    if ( pollid == 18 ) { gastype <<- "gas21" }
    
    print(paste("--->APPLYNUDGES: ", username, sep = ""))
    source("dogasnudges.R", echo = TRUE )
  }
   
  if ( ! is.na(pushoveruser) ) {
    print(paste("--->PUSHNOTIFICATION: ", username, sep = ""))
    source("dogasnotifications.R", echo = TRUE )
  }
   
  print(paste("--->PLOTS: ", username, sep = ""))
  source("dogasplots.R", echo = TRUE )
   
}

dbDisconnect(con)
#system("cd ~/websites/nudge; git add .; git commit -m 'X'; git push")
