#!/bin/bash

source ./common.sh
check_root

dnf module disable redis -y  &>>$LOG_FILE
VALIDATE $? "Disabling current module"
dnf module enable redis:7 -y   &>>$LOG_FILE
VALIDATE $? "Enabling latest module 7"
dnf install redis -y   &>>$LOG_FILE
VALIDATE $? "Installing redis module"
sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf  
VALIDATE $? "Allowing remote connections to redis"
systemctl enable redis  &>>$LOG_FILE
VALIDATE $? "Enabling redis"
systemctl start redis   &>>$LOG_FILE
VALIDATE $? "Starting redis"

print_total_time