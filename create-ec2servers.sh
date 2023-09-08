#!/bin/bash

# This script is used for creating EC2 instances
echo "This script is used for creating EC2 instances"

# Define variables
INSTANCE_TYPE="t2.micro"
AMI_ID="ami-03265a0778a880afb"
AWS_SG="sg-0fd38dba987f6a767"
DOMAIN_NAME="myroboshop.site"
HOSTEDZONE_ID="Z08892663AT899M4JPPZH"

# Loop through instance names provided as arguments
for instance_name in "$@"
do
    echo "Creating $instance_name instance"

    # Create the EC2 instance and capture the Private IP address
    IP_ADDRESS=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type $INSTANCE_TYPE \
        --security-group-ids $AWS_SG \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance_name}]" | jq -r '.Instances[0].PrivateIpAddress')

    if [ -n "$IP_ADDRESS" ]; then
        echo "Created $instance_name instance with Private IP: $IP_ADDRESS"

        # Optionally, add more configuration steps here if needed

    else
        echo "Failed to create $instance_name instance"
    fi

    # Optionally, associate the instance with a Route 53 hosted zone
    # aws route53 change-resource-record-sets ...

done
          