#!/bin/bash

# This script is used for creating EC2 instances and updating Route 53 records if needed
echo "This script is used for creating EC2 instances and updating Route 53 records if needed"

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

    if [ $? -eq 0 ]; then
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
    else
        echo "Error: Failed to check $instance_name instance. Error Message: $existing_instance"
    fi

    # Check if a Route 53 record already exists for the instance name
    existing_record=$(aws route53 list-resource-record-sets --hosted-zone-id $HOSTEDZONE_ID --query "ResourceRecordSets[?Name == '$instance_name.$DOMAIN_NAME.']" 2>&1)

    if [ $? -eq 0 ]; then
        if [ -n "$existing_record" ]; then
            echo "Updating Route 53 record for $instance_name..."
            aws route53 change-resource-record-sets --hosted-zone-id $HOSTEDZONE_ID --change-batch '{
                "Comment": "UPDATE a record",
                "Changes": [{
                    "Action": "UPSERT",
                    "ResourceRecordSet": {
                        "Name": "'$instance_name.$DOMAIN_NAME.'",
                        "Type": "A",
                        "TTL": 0,
                        "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                    }
                }]
            }'
        else
            echo "Creating Route 53 record for $instance_name..."
            aws route53 change-resource-record-sets --hosted-zone-id $HOSTEDZONE_ID --change-batch '{
                "Comment": "CREATE a record",
                "Changes": [{
                    "Action": "CREATE",
                    "ResourceRecordSet": {
                        "Name": "'$instance_name.$DOMAIN_NAME.'",
                        "Type": "A",
                        "TTL": 0,
                        "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                    }
                }]
            }'
        fi
    else
        echo "Error: Failed to check Route 53 record for $instance_name. Error Message: $existing_record"
    fi
done
