#!bin/bash

function createInstance() {
    name=$1
    groupId=$2
    subnetId=$3
    keyName=$4
    s3_instance=$(aws ec2 run-instances --tag-specifications \
        'ResourceType=instance,Tags=[{Key=Name,Value='$name'},{Key=tbd,Value="true"}]' \
        --image-id ami-007855ac798b5175e \
        --count 1 \
        --instance-type t2.micro \
        --key-name $keyName \
        --security-group-ids $groupId \
        --subnet-id $subnetId \
        --output json \
    )
}