#!/bin/bash

#Giving the colours
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

dnf install python36 gcc python3-devel -y &>> $LOG_FILE
VALIDATE $? "Installing Python Package"

id roboshop &>> $LOG_FILE
if [ $? -ne "0" ]
then 
    useradd roboshop &>> $LOG_FILE
    VALIDATE $? "Creating Roboshop User"
else 
    echo -e "Roboshop User already Exist...$Y SKIPPING$N"
fi 

mkdir -p /app &>> $LOG_FILE
VALIDATE $? "Creating App directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOG_FILE
VALIDATE $? "Downloading payment.zip"

cd /app 

unzip -o /tmp/payment.zip &>> $LOG_FILE
VALIDATE $? "Unzipping payment.zip"

pip3.6 install -r requirements.txt &>> $LOG_FILE
VALIDATE $? "Installing Dependencies"

cp /home/centos/AWS-DevOps/roboshop-shell/payment.service /etc/systemd/system/payment.service &>> $LOG_FILE
VALIDATE $? "Copying payment.service file"

systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "daemon Reaload"

systemctl enable payment &>> $LOG_FILE
VALIDATE $? "Enabling Payment"

systemctl start payment &>> $LOG_FILE
VALIDATE $? "Starting Payment"