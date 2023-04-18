#!/bin/bash

source utils/vpc.sh
source utils/instance.sh
source utils/subnet.sh

#VPC_ARG="$1"
SUBNET_ARG="$1"
SG_ARG="$2"
#INSTANCE_TYPE="$4"
#KEY_ID="$5"

SUBNET_ID_PATTERN="subnet-[a-z0-9]*"
SG_ID_PATTERN="sg-[a-z0-9]*"
SG_PORT_PATTERN="[0-9]+:[0-9]+"


if [[ $SUBNET_ARG == $SUBNET_ID_PATTERN ]]; then
    echo "Subnet argument is an ID, checking Security Group argument"
    if [[ $SG_ARG == $SG_ID_PATTERN ]]; then
        echo "Security Group argument is an ID, checking for an existing VPC"
        
        describe_vpc
        echo "VPC exists with ID $VPC_ID"
        
        describe_subnet_vpc
        echo "Subnet is connected to $SUBNET_VPC_ID"
        
        describe_sg_vpc
        echo "$SG_VPC_ID $VPC_ID $SUBNET_VPC_ID"
        echo "Secirity Group is connected to $SG_VPC_ID"
        
        if [ "$VPC_ID" == "$SUBNET_VPC_ID" ] && [ "$VPC_ID" == "$SG_VPC_ID" ]; then
            echo "$SUBNET_VPC_ID is a part of $VPC_ID"
        else
            echo "$SUBNET_VPC_ID is not a part of $VPC_ID" && exit
        fi
    elif [[ $SG_ARG == $SG_PORT_PATTERN ]]; then
        ports="left:right"
        IFS=":" read -ra parts <<< "$ports"
        left="${parts[0]}"
        right="${parts[1]}"
        
        describe_subnet_vpc
        if [ -n $SUBNET_VPC_ID ]; then
            create_sg_in_vpc
        else 
            echo "No VPC available, exiting" && exit
        fi
    else
        echo "Unexpected argument for Security Group" 
    fi
    elif [[ $SUBNET_ARG == "public" ]]; then
        if [[ $SG_ARG == $SG_ID_PATTERN ]]; then
            describe_sg_vpc
            create_public_subnet
        elif [[ $SG_ARG == $SG_PORT_PATTERN ]]; then
            create_vpc
            create_public_subnet
            create_sg
        else
            echo "error pub"
        fi
    elif [[ $SUBNET_ARG == "private" ]]; then
        if [[ $SG_ARG == $SG_ID_PATTERN ]]; then
            describe_sg_vpc
            create_public_subnet
        elif [[ $SG_ARG == $SG_PORT_PATTERN ]]; then
            create_vpc
            create_private_subnet
            create_sg
        else
            echo "error priv"
        fi
    else
        echo "error out"
fi