#!/bin/bash

id roboshop
if [ $? -ne "0" ]
then 
    echo "User already Exist...SKIPPING"
else 
    echo "Adding user"
fi