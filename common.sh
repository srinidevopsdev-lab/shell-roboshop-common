#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE=$LOGS_FOLDER/$SCRIPT_NAME.log
START_TIME=$(date +%s)
SCRIPT_DIR=$PWD
MYSQL_HOST="mysql.srinivasa.fun"
MONGODB_HOST=mongodb.srinivasa.fun
mkdir -p $LOGS_FOLDER
echo "script started executed at: $(date)" | tee -a $LOG_FILE

check_root(){
    if [ $USERID -ne 0 ]; then
        echo "Error::Please run this script as root user"
        exit 1 # failure is othere than 0 Means it will stop here dont run furthur
    fi
}

VALIDATE () {
    if [ $1 -ne 0 ]; then
        echo -e "Error: $2 ... $R failure $N" | tee -a $LOG_FILE
        exit 1 # 1 for failure
    else
        echo -e "$2 ... $G successful $N" | tee -a $LOG_FILE
    fi
}
nodejs_setup(){

    dnf module disable nodejs -y  &>>$LOG_FILE
    VALIDATE $? "Disable current module"
    dnf module enable nodejs:20 -y  &>>$LOG_FILE
    VALIDATE $? "Enable required module"
    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "Installing nodejs"
    npm install  &>>$LOG_FILE
    VALIDATE $? "npm installing"
}
java_setup(){
    dnf install maven -y &>>$LOG_FILE
    VALIDATE $? "Installing maven"

    mvn clean package &>>$LOG_FILE 
    VALIDATE $? "unzip shipping content"

    mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
    VALIDATE $? "unzip shipping content"
}
app_setup() {
    id roboshop 
    if [ $? -ne 0 ]; then    
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        VALIDATE $? "roboshop user is created"
    else
        echo -e "User already exist ....$Y skipping $N"
    fi
    mkdir -p /app 
    VALIDATE $? "creating app directory"

    curl -o /tmp/$app_name.zip https://roboshop-artifacts.s3.amazonaws.com/$app_name-v3.zip  &>>$LOG_FILE
    VALIDATE $? "Downloading $app_name content"

    cd /app 
    VALIDATE $? "Changing to app directory"

    rm -rf /app/*
    VALIDATE $? "removing old"

    unzip /tmp/$app_name.zip &>>$LOG_FILE
    VALIDATE $? "unzip $app_name content"
}
systemd_setup() {   
    cp $SCRIPT_DIR/$app_name.service /etc/systemd/system/$app_name.service
    VALIDATE $? "copying $app_name.service"

    systemctl daemon-reload
    VALIDATE $? "deamon reload"

    systemctl enable $app_name  &>>$LOG_FILE
    VALIDATE $? "Enable $app_name"
}

app_restarted(){
    systemctl restart $app_name 
    VALIDATE $? "Restarting $app_name"
}
print_total_time() {
    END_TIME=$(date +%s)
    TOTAL_TIME=$(($END_TIME - $START_TIME))
    echo -e "Script executed time: $Y $TOTAL_TIME $N"
}