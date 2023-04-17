#!/bin/bash

create_subnet ()
{
    SUBNET_ID=$(aws ec2 create-subnet \
	    --vpc-id $VPC_ID \
        --cidr-block 10.0.1.0/24 \
        --availability-zone us-east-1a \
        --query 'Subnet.{SubnetId:SubnetId}' \
        --output text)

    if [ -z "$SUBNET_ID" ]; then
        echo "Subnet ID is empty, exiting..." && return 1
    else
        aws ec2 create-tags \
            --resources $SUBNET_ID \
            --tags Key=DeleteMe,Value=Yes

        echo "$SUBNET_ID created and tagged"

        aws ec2 modify-subnet-attribute \
	        --subnet-id $SUBNET_ID \
	        --map-public-ip-on-launch

        echo "Auto-assign public IP for $SUBNET_ID enabled"
    fi
}

delete_subnet ()
{
    SUBNET_ID=$(aws ec2 describe-subnets \
	    --filters "Name=tag:DeleteMe,Values=Yes" \
	    --query 'Subnets[*].SubnetId' \
	    --output text)

    aws ec2 delete-subnet \
	    --subnet-id $SUBNET_ID
}
