#!/bin/bash

create_public_subnet()
{
	SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID  --cidr-block 10.0.1.0/24 --availability-zone us-east-1a --query 'Subnet.{SubnetId:SubnetId}' --output text)
	if [ -z "$SUBNET_ID" ]; then
        echo "Error creating subnet!"
        exit 1
    fi
    aws ec2 create-tags --resources "$SUBNET_ID" --tags Key=tbd,Value=True
    echo "$SUBNET_ID created and tagged"
    aws ec2 modify-subnet-attribute --subnet-id "${SUBNET_ID}" --map-public-ip-on-launch
	if [ "$?" -ne 0 ]; then
             echo "Error enabling auto-assign public IP addresses!"
             exit 1
        else
             echo "Auto-assign public IP addresses enabled for subnet ${SUBNET_ID}!"
    fi
}

create_private_subnet()
{
	SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID  --cidr-block 10.0.1.0/24 --availability-zone us-east-1a --query 'Subnet.{SubnetId:SubnetId}' --output text)
    if [ -z "$SUBNET_ID" ]; then
        echo "Error creating subnet!"
        exit 1
    fi
    aws ec2 create-tags --resources "$SUBNET_ID" --tags Key=tbd,Value=True
    	echo "$SUBNET_ID created and tagged"
}

describe_subnet_vpc()
{
	SUBNET_VPC_ID=$(aws ec2 describe-subnets --query 'Subnets[*].VpcId' --filters "Name=tag:tbd,Values=True" --output text)
}

delete_subnet ()
{
	SUBNET_ID=$(aws ec2 describe-subnets --filters "Name=tag:tbd,Values=True" --query 'Subnets[*].SubnetId' --output text)
	aws ec2 delete-subnet --subnet-id $SUBNET_ID
}
