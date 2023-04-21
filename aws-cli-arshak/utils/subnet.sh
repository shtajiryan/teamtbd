#!bin/bash

function createSubnet() {
    sub_name="$1 Subnet"
    subNetCidrBlock="10.0.1.0/24"
    zone=$2
    vpcId=$3
    flag=$4
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
    if [[ $flag=="public" ]];
    then
        modify_response=$(
            aws ec2 modify-subnet-attribute \
            --subnet-id "$subnetId" \
            --map-public-ip-on-launch
        )
    else
        modify_response=$(
            aws ec2 modify-subnet-attribute \
            --subnet-id "$subnetId"
        )
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

function describeSubnet() {
    TAG_KEY=$1
    TAG_VALUE=$2
    sbIds=$(
        aws ec2 describe-subnets \
        --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" \
        --query 'Subnets[].SubnetId' \
        --output text \
        2>&1
    )
}

function deleteSubnet() {
    ids=$1
    for id in $ids;
    do
        aws ec2 delete-subnet --subnet-id "$id"
    done
}