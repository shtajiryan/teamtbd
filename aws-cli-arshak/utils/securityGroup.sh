#!/bin/bash


function createSecurityGroup() {
    scg_name="$1 Security Group"
    portCidrBlock="0.0.0.0/0"
    port=$2
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

    security_response2=$(aws ec2 authorize-security-group-ingress \
        --group-id "$groupId" \
        --protocol tcp --port "$port" \
        --cidr "$portCidrBlock"
    )
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