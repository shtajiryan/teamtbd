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