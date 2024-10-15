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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOG_FILE
VALIDATE $? "Configuring YUM Repos"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOG_FILE
VALIDATE $? "Configure YUM Repos for RabbitMQ"

dnf install rabbitmq-server -y &>> $LOG_FILE
VALIDATE $? "Install RabbitMQ"

systemctl enable rabbitmq-server &>> $LOG_FILE
VALIDATE $? "Enabling RabbitMQ"

systemctl start rabbitmq-server &>> $LOG_FILE
VALIDATE $? "Starting RabbitMQ"

rabbitmqctl add_user roboshop roboshop123 &>> $LOG_FILE
VALIDATE $? "Creating roboshop user and password"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOG_FILE
VALIDATE $? "Giving the permissions to roboshop user"

