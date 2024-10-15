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

dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disabling NodeJs 10"

dnf module enable nodejs:18 -y &>> $LOG_FILE
VALIDATE $? "Enabling NodeJs 18"

dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "Installing NodeJs"

id roboshop
if [ $? -ne "0" ]
then 
    useradd roboshop &>> $LOG_FILE
    VALIDATE $? "Creating Roboshop User"
else 
    echo -e "Roboshop User already Exist...$Y SKIPPING$N"
fi 


mkdir -p /app &>> $LOG_FILE
VALIDATE $? "Create App Directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOG_FILE
VALIDATE $? "Download Catalogue Application"

cd /app &>> $LOG_FILE
VALIDATE $? "Go to App Directory"

unzip -o /tmp/catalogue.zip &>> $LOG_FILE
VALIDATE $? "Unzipping Catalogue Application"

npm install &>> $LOG_FILE
VALIDATE $? "Installing NodeJS Dependencies"

cp /home/centos/AWS-DevOps/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOG_FILE
VALIDATE $? "Copying Catalogue.service"

systemctl daemon-reload  &>> $LOG_FILE
VALIDATE $? "Daemon Reaload"

systemctl enable catalogue &>> $LOG_FILE
VALIDATE $? "Ebnable Catalogue"

systemctl start catalogue &>> $LOG_FILE
VALIDATE $? "Start Catalogue"

cp /home/centos/AWS-DevOps/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE
VALIDATE $? "Copying Mongo Repo"

dnf install mongodb-org-shell -y &>> $LOG_FILE
VALIDATE $? "Install MongoDB Client"

mongo --host mongodb.learndevops.space </app/schema/catalogue.js &>> $LOG_FILE
VALIDATE $? "Pushing Products into MongoDB Server" 
