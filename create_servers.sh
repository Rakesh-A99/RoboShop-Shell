#!/bin/bash
Names=$@
INSTANCE_TYPE=""
IMAGE_ID=ami-03265a0778a880afb
SECUIRTY_GROUP_ID=sg-0fd38dba987f6a767
DOMAIN_NAME=myroboshop.site
HOSTED_ZONE=Z08892663AT899M4JPPZH

for i in $@
do
    echo "creating $i instance"
    IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID  --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GROUP_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
    echo "created $i instance: $IP_ADDRESS"
    aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch'
    {
        "Comment": "CREATE a record ",
            "Changes": [{
            "Action": "CREATE",
                        "ResourceRecordSet": {
                                    "Name": "'$i.$DOMAIN_NAME'",
                                    "Type": "A",
                                    "TTL": 300,
                                    "ResourceRecords": [{ "Value": "'$IP_ADDRESS'"}]
                                    }}]
    }'
 done
