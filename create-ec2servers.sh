#!/bin/bash

# this is script is used for creating the ec2 instances
# variables assigning
echo "This script is used for creating the ec2 instances"
NAME=$@
INSTANCE_TYPE=t2.micro
AMI_ID=ami-03265a0778a880afb
AWS_SG=sg-0fd38dba987f6a767
DOMAIN_NAME=myroboshop.site
HOSTEDZONE_ID=Z08892663AT899M4JPPZH
for i in $@
do 
    echo "creating $i instance"
    IPADDRESS=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t2.micro --security-group-ids $AWS_SG --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]") 
    Instance_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$i")
    echo "$Instance_ID="
    echo "creating $i instance : $IPADDRESS"
done             