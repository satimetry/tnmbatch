#!/bin/sh

echo "Check jenkins server application status ..."
restart=`rhc app show --state jenkins -p Dopamine@1 | egrep "idle|stopped" | wc -l`
echo $restart
if [ $restart != "0" ]; then
  echo "Jenkins Application is starting"
else
  echo "Jenkins Application is already started"
fi

