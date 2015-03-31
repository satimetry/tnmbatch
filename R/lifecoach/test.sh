#!/bin/sh

PASSWORD=$1
echo $PASSWORD

echo "Check jenkins server application status ..."
restart=`rhc app show --state jenkins -p $PASSWORD | egrep "idle|stopped" | wc -l`
echo $restart
if [ $restart != "0" ]; then
  echo "Jenkins Application is starting"
else
  echo "Jenkins Application is already started"
fi

