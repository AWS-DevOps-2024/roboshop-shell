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

dnf install nginx -y &>> $LOG_FILE
VALIDATE $? "Installing Nginx"
 
systemctl enable nginx &>> $LOG_FILE
VALIDATE $? "Enabling Nginx"

systemctl start nginx &>> $LOG_FILE
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>> $LOG_FILE
VALIDATE $? "Removing Default Nginx HTML Content"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOG_FILE
VALIDATE $? "Downloading web.zip"

cd /usr/share/nginx/html &>> $LOG_FILE
VALIDATE $? "Go to nginx html directory"

unzip -o /tmp/web.zip &>> $LOG_FILE
VALIDATE $? "Unzipping web.zip"

cp /home/centos/AWS-DevOps/roboshop-shell/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOG_FILE
VALIDATE $? "Creating Reverse Proxy"

systemctl restart nginx &>> $LOG_FILE
VALIDATE $? "Restarting Nginx"