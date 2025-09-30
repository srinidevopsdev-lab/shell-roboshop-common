#!/bin/bash

source ./common.sh
check_root

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo  &>>$LOG_FILE
VALIDATE $? "Copying rabbitmq repo"
dnf install rabbitmq-server -y  &>>$LOG_FILE
VALIDATE $? "Installing rabbitmq "
systemctl enable rabbitmq-server  &>>$LOG_FILE
VALIDATE $? "Enabling rabbitmq "
systemctl start rabbitmq-server  &>>$LOG_FILE
VALIDATE $? "Starting rabbitmq"
rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
VALIDATE $? "Adding rabbitmq user"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATE $? "Set permissions rabbitmq"

print_total_time