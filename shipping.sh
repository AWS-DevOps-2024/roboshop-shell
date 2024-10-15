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

dnf install maven -y &>> $LOG_FILE
VALIDATE $? "Installing Maven Package"

id roboshop
if [ $? -ne "0" ]
then 
    useradd roboshop &>> $LOG_FILE
    VALIDATE $? "Creating Roboshop User"
else 
    echo -e "Roboshop User already Exist...$Y SKIPPING$N"
fi 

mkdir -p /app &>> $LOG_FILE
VALIDATE $? "Creating App directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOG_FILE
VALIDATE $? "Downloading shipping.zip"

cd /app

unzip -o /tmp/shipping.zip &>> $LOG_FILE
VALIDATE $? "unzipping shipping.zip"

mvn clean package &>> $LOG_FILE
VALIDATE $? "Installing Dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOG_FILE
VALIDATE $? "Renaming shipping-1.0.jar file to shipping.jar"

cp /home/centos/AWS-DevOps/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOG_FILE
VALIDATE $? "Copying Shipping.Servcie file"

systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "Daemon Realod"

systemctl enable shipping &>> $LOG_FILE
VALIDATE $? "Enabling Shipping"

systemctl start shipping &>> $LOG_FILE
VALIDATE $? "Starting Shipping"

dnf install mysql -y &>> $LOG_FILE
VALIDATE $? "Installing MySQL Client"

mysql -h mysql.learndevops.space -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>> $LOG_FILE
VALIDATE $? "Pushing Shipping Packages to MySQL"

systemctl restart shipping &>> $LOG_FILE
VALIDATE $? "Restarting Shipping"
