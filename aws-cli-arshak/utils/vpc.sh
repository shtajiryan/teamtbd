#!/bin/bash

function createVpc() {
    vpc_name="$1 VPC"
    vpcCidrBlock=$2
    vpcId=0
    aws_response=$(
        aws ec2 create-vpc \
        --cidr-block "$vpcCidrBlock" \
        --output json
    )

    vpcId=$(echo -e "$aws_response" | /usr/bin/jq '.Vpc.VpcId' | tr -d '"')

    #name the vpc
    aws ec2 create-tags \
    --resources "$vpcId" \
    --tags Key=Name,Value="$vpc_name"

    # add tag tbd
    aws ec2 create-tags \
    --resources "$vpcId" \
    --tags Key=tbd,Value="true"

    #add dns support
    modify_response=$(aws ec2 modify-vpc-attribute \
        --vpc-id "$vpcId" \
        --enable-dns-support "{\"Value\":true}")

    #add dns hostnames
    modify_response=$(aws ec2 modify-vpc-attribute \
        --vpc-id "$vpcId" \
        --enable-dns-hostnames "{\"Value\":true}"
    )
}

function describeVPC() {
    TAG_KEY=$1
    TAG_VALUE=$2
    vpcIds=$(
        aws ec2 describe-vpcs \
        --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" \
        --query 'Vpcs[*].VpcId' \
        --output text \
        2>&1
    )
}

function deleteVpc() {
    ids=$1
    for id in $ids;
    do
        aws ec2 delete-vpc --vpc-id "$id"
    done
}