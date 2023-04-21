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

function describeInstance() {
    TAG_KEY=$1
    TAG_VALUE=$2
    instanceIds=$(
        aws ec2 describe-instances \
        --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" \
        --query "Reservations[*].Instances[*].InstanceId" \
        --output text)
}

function deleteInstance() {
    ids=$1
    for id in $ids;
    do
        aws ec2 terminate-instances --instance-ids "$id"
        aws ec2 wait instance-terminated --instance-ids "$id"
    done
}