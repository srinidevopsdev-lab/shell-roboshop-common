#!/bin/bash

source ./common.sh
app_name=catalogue
check_root
app_setup
nodejs_setup
systemd_setup

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongo.repo"

dnf install mongodb-mongosh -y  &>>$LOG_FILE
VALIDATE $? "installing mongodb client"

INDEX=$(mongosh mongodb.srinivasa.fun --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js  &>>$LOG_FILE
    VALIDATE $? "load $app_name products"
else
    echo -e "$app_name products are already loaded...$Y Skipping $N"
fi

app_restarted
print_total_time