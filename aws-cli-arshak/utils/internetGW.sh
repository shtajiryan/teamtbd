#!bin/bash

function getVpcId_IGWById() {
    internet_gateway_id=$1

    igwVpcId=$( aws ec2 describe-internet-gateways \
        --internet-gateway-ids $internet_gateway_id \
        --query 'InternetGateways[0].Attachments[0].VpcId' \
        --output text
    )
}

function attachVpc() {
    gatewayId=$1
    vpcId=$2

    attach_response=$(aws ec2 attach-internet-gateway \
    --internet-gateway-id "$gatewayId"  \
    --vpc-id "$vpcId")
}

function createGatewayAndAttachVpc() {
    igw_name="$1 Gateway"
    vpcId=$2
    gatewayId=0
    gateway_response=$(aws ec2 create-internet-gateway \
	--output json)

    gatewayId=$(echo -e "$gateway_response" |  /usr/bin/jq '.InternetGateway.InternetGatewayId' | tr -d '"')

    #add name the internet gateway
    $(
        aws ec2 create-tags \
        --resources "$gatewayId" \
        --tags Key=Name,Value="$igw_name"
    )
    #add tbdTag the internet gateway
    $(
        aws ec2 create-tags \
        --resources "$gatewayId" \
        --tags Key=tbd,Value="true"
    )

    #attach gateway to vpc
    attachVpc "$gatewayId" "$vpcId"
}

function describeIGW() {
    TAG_KEY=$1
    TAG_VALUE=$2
    igwIds=$( aws ec2 describe-internet-gateways \
        --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" \
        --query 'InternetGateways[].InternetGatewayId' \
        --output text
    )
}

function deleteIGW() {
    ids=$1
    for id in $ids;
    do
        getVpcId_IGWById "$id"
        aws ec2 detach-internet-gateway \
            --internet-gateway-id $id \
            --vpc-id $igwVpcId

        aws ec2 delete-internet-gateway --internet-gateway-id "$id"
    done
}