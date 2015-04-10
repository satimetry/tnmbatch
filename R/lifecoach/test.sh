#!/bin/sh

PASSWORD=$1
echo $PASSWORD

cd /Users/stefanopicozzi/tnm/tnmbatch
git pull
git add .
git commit -am "dolifecoach crontab batch script tnmbatch"
git push

cd /Users/stefanopicozzi/websites/nudge
git pull
git add images
git commit -am "dolifecoach crontab batch script website images"
git push

