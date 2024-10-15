#!/bin/bash

R="\e[31m"
G="\e[32m"
N="\e[0m"

instances=("mongodb" "mysql" "redis" ""rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web" )
zone_id="Z02357183AC34D1F7B6MH"

for i in "${instances[@]}"
do
    if [ $i == "mongodb" ] || [ $i == "mysql" ]
    then 
        instance_type="t2.small"
    else
        instance_type="t2.micro"
    fi
    IP_ADDRESS=$(aws ec2 run-instances --image-id ami-0b4f379183e5706b9 --instance-type $instance_type --security-group-ids sg-04d3cc3675c0c646f --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)
    echo -e "$i:: $G$IP_ADDRESS$N"



# aws ec2 run-instances --image-id ami-0b4f379183e5706b9 --instance-type t2.micro --security-group-ids sg-04d3cc3675c0c646f --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Web}]'

aws route53 change-resource-record-sets \
  --hosted-zone-id $zone_id \
  --change-batch '
  {
    "Comment": "Creating a record set for cognito endpoint"
    ,"Changes": [{
      "Action"              : "UPSERT"
      ,"ResourceRecordSet"  : {
        "Name"              : "'$i'.learndevops.space"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$IP_ADDRESS'"
        }]
      }
    }]
  }'

done