#!/bin/sh

PASSWORD=$1
echo $PASSWORD

cd /Users/stefanopicozzi/tnm/tnmbatch
git pull
git add .
git commit -am "dolifecoach crontab batch script tnmbatch"
git push

echo "Hello" 
cd /Users/stefanopicozzi/websites/nudge
git pull
echo "Hello again" 
git add images
git commit -am "dolifecoach crontab batch script website images"
git push

