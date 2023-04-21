#!/bin/bash


function createSecurityGroup() {
    scg_name="$1 Security Group"
    portCidrBlock="0.0.0.0/0"
    ports=$2
    vpcId=$3
    groupId=0
    security_response=$(aws ec2 create-security-group \
        --group-name "$scg_name" \
        --description "Public: $scg_name" \
        --vpc-id "$vpcId" --output json
    )
    groupId=$(echo -e "$security_response" |  /usr/bin/jq '.GroupId' | tr -d '"')

    #name the security group
    aws ec2 create-tags \
    --resources "$groupId" \
    --tags Key=Name,Value="$scg_name" \

    aws ec2 create-tags \
    --resources "$groupId" \
    --tags Key=tbd,Value="true"
    #enable port 22

    for i in $ports;
    do
        if [[ $i =~ ^([0-9]{2,5})$ ]];
        then
            security_response2=$(aws ec2 authorize-security-group-ingress \
                --group-id "$groupId" \
                --protocol tcp --port "$i" \
                --cidr "$portCidrBlock"
            )
        fi
    done
}

function checkSGById() {
    Id=$1

    groupId=$(aws ec2 describe-security-groups \
        --group-ids "$Id" \
        --query 'SecurityGroups[0].GroupId' \
        --output text \
        2>&1
    )
}

function getVpcIdBySG_Id() {
    groupId=$1

    sgVpcId=$(aws ec2 describe-security-groups \
        --group-ids "$groupId" \
        --query 'SecurityGroups[0].VpcId' \
        --output text \
        2>&1
    )
}

function describeSecurityGroup() {
    TAG_KEY=$1
    TAG_VALUE=$2
    sgId=$(
        aws ec2 describe-security-groups \
        --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" \
        --query "SecurityGroups[].GroupId" \
        --output text
    )
}

function deleteSecurityGroup() {
    ids=$1
    for id in $ids;
    do
        aws ec2 delete-security-group --group-id $id
    done
}