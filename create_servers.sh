#!/bin/bash
Names=$@
INSTANCE_TYPE=""
IMAGE_ID=ami-03265a0778a880afb
SECUIRTY_GROUP_ID=sg-0fd38dba987f6a767
DOMAIN_NAME=myroboshop.site
HOSTED_ZONE=Z08892663AT899M4JPPZH

for i in $@
do  
    INSTANCE_EXISTS=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$i" --query 'Reservations[].Instances[0].InstanceId' --output text)
    if [[ $i == "mongodb" || $i == "mysql" ]]
    then
        INSTANCE_TYPE="t3.medium"
    else
        INSTANCE_TYPE="t2.micro"
    fi
    if [ -n "$instance_exists" ]; 
    then
    echo "Instance already exists with ID: $instance_exists"
    else
     # Create a new EC2 instance
    echo "Creating a new EC2 instance..."
    echo "creating $i instance"
    IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID  --instance-type $INSTANCE_TYPE --security-group-ids $SECUIRTY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
    echo "created $i instance: $IP_ADDRESS"
    fi
    dns_info=$(aws route53 list-resource-record-sets --hosted-zone-id "${HOSTED_ZONE}")

    # Extract the DNS name if it exists
    existing_dns_name=$(echo "$dns_info" | jq -r '.ResourceRecordSets[] | select(.Name == "'${DOMAIN_NAME}'") | .Name')

    if [ -n "$existing_dns_name" ]; then
    echo "DNS name already exists: $existing_dns_name"
    else
    aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE --change-batch '
    {
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                            "Name": "'$i.$DOMAIN_NAME'",
                            "Type": "A",
                            "TTL": 300,
                            "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                        }}]
    }
    '
    fi
done