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
    echo "Checking if $instance_name instance already exists..."

    # Use describe-instances to check if an instance with the same name tag exists
    existing_instance=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$instance_name")

    if [ -z "$existing_instance" ]; then
        echo "$instance_name instance does not exist. Creating..."

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
    else
        echo "$instance_name instance already exists. Skipping..."
    fi

    # Optionally, associate the instance with a Route 53 hosted zone
    # aws route53 change-resource-record-sets ...

done
