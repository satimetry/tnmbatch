#!/bin/sh

# www.openshift.com
# login: spicozzi@redhat.com
# app: nudge
# alias: www.satimetry.com

echo "Show domain status ..."
rhc domain show -p Dopamine@1

echo "Check nudge database application status ..."
restart=`rhc app show --state nudgedb -p Dopamine@1 | egrep "idle|stopped" | wc -l`
if [ $restart > 0 ]; then
  echo "Application is starting"
  rhc app start nudgedb -p Dopamine@1
else
  echo "Nudge Database Application is started"
fi

echo "Check nudge client application status ..."
restart=`rhc app show --state nudgedb -p Dopamine@1 | egrep "idle|stopped" | wc -l`
if [ $restart > 0 ]; then
  echo "Application is starting"
  rhc app start nudge -p Dopamine@1
else
  echo "Nudge Client Application is started"
fi

echo "Check nudge server application status ..."
restart=`rhc app show --state nudgedb -p Dopamine@1 | egrep "idle|stopped" | wc -l`
if [ $restart > 0 ]; then
  echo "Application is starting"
  rhc app start nudgeserver -p Dopamine@1
else
  echo "Nudge Server Application is started"
fi

cd ~/tnm/tnmbatch/R/lifecoach

echo "Do GAS ..."
./dogas/dogas.R

echo "Do fitbit ..."
./dofitbit/dofitbit.R

echo "Do fitbit ..."
./dowithings/dowithings.R

cd ~/websites/nudge
git add images
git commit -am "dolifecoach crontab batch script"
git push
