#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

ID=$(id -u)
LOG_FILE="/tmp/$0-$(date +%F--%T).log"

VALIDATE() {
    if [ $1 -ne "0" ]
    then    
        echo -e "$2...$R FAILED$N"
        exit 1
    else
        echo -e "$2...$G SUCCESS$N"
    fi
}    
    
#Check if you are a root user or not

if [ $ID -ne "0" ]
then    
    echo -e "$R ERROR$N:: You are not a Root User, Please run this with root access."
    exit 1
else
    echo -e "You are a Root User...$G PROCEED$N"
fi

dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disabling NodeJS 10"

dnf module enable nodejs:18 -y &>> $LOG_FILE
VALIDATE $? "Enabling NodeJS 18"

dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "Installing NodeJS"

id roboshop
if [ $? -ne "0" ]
then
    useradd roboshop &>> $LOG_FILE
    VALIDATE $? "Creating Roboshop User"
else
    echo -e "Roboshop User already Exists...$Y SKIPPING$N"
fi

mkdir -p /app &>> $LOG_FILE
VALIDATE $? "Creating App Directory"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOG_FILE
VALIDATE $? "Downloading User.zip"

cd /app 

unzip -o /tmp/cart.zip &>> $LOG_FILE
VALIDATE $? "Unzipping cart.zip"

npm install &>> $LOG_FILE
VALIDATE $? "Installing Dependencies"

cp /home/centos/AWS-DevOps/roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOG_FILE
VALIDATE $? "Copying cart.service file"

systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "Daemon Reload"

systemctl enable cart &>> $LOG_FILE
VALIDATE $? "Enabling cart"

systemctl start cart &>> $LOG_FILE
VALIDATE $? "Stating cart"

