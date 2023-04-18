#!bin/bash

function createSubnet() {
    sub_name="$1 Subnet"
    subNetCidrBlock="10.0.1.0/24"
    zone=$2
    vpcId=$3
    subnetId=0
    #create Subnet
    subnet_response=$(aws ec2 create-subnet \
    --cidr-block "$subNetCidrBlock" \
    --availability-zone "$zone" \
    --vpc-id "$vpcId" \
    --output json)
    subnetId=$(echo -e "$subnet_response" |  /usr/bin/jq '.Subnet.SubnetId' | tr -d '"')

    #name the subnet
    aws ec2 create-tags \
    --resources "$subnetId" \
    --tags Key=Name,Value="$sub_name" \

    aws ec2 create-tags \
    --resources "$subnetId" \
    --tags Key=tbd,Value="true"

    #enable public ip on subnet
    modify_response=$(aws ec2 modify-subnet-attribute \
    --subnet-id "$subnetId" \
    --map-public-ip-on-launch)
    if [ "${subnetId}" == 0 ]; then
        message="create Subnet Error"
    fi
}

function checkSubnetById() {
    subId=$1
    subnetId=$( aws ec2 describe-subnets \
        --subnet-ids "$subId" \
        --query 'Subnets[0].SubnetId' \
        --output text \
        2>&1
    )
    echo $subnetId
}

function getVpcInSubnet() {
    subId=$1
    subVpcId=$( aws ec2 describe-subnets \
        --subnet-ids "$subId" \
        --query 'Subnets[0].VpcId' \
        --output text \
        2>&1
    )
    echo $subVpcId
}