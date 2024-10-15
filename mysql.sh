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

dnf module disable mysql -y &>> $LOG_FILE
VALIDATE $? "Diabling MySQL"

cp /home/centos/AWS-DevOps/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOG_FILE
VALIDATE $? "Copying MySQL Repo"

dnf install mysql-community-server -y &>> $LOG_FILE
VALIDATE $? "Installing MySQL"

systemctl enable mysqld &>> $LOG_FILE
VALIDATE $? "Enabling MySQL"

systemctl start mysqld &>> $LOG_FILE
VALIDATE $? "Starting MySQL"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOG_FILE
VALIDATE $? "Setting the MySQL root Password"

