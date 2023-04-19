#!/bin/bash

source utils/vpc.sh
source utils/instance.sh
source utils/subnet.sh
source utils/portparse.sh

VPC_ARG="$1"
SUBNET_ARG="$2"
SG_ARG="$3"
INSTANCE_IMAGE_ID="$4"
KEY_PAIR="$5"

INSTANCE_IMAGE_ID_PATTERN="ami-[a-z0-9]*"
SUBNET_ID_PATTERN="subnet-[a-z0-9]*"
SG_ID_PATTERN="sg-[a-z0-9]*"
SG_PORT_PATTERN="[0-9]+(:[0-9]+)*$"
VPC_ID_PATTERN="vpc-[a-z0-9]*"

if  [[ $VPC_ARG == $VPC_ID_PATTERN ]]; then
    echo "VPC argument is an ID, checking for an existing VPC"
    describe_vpc
    if [[ $VPC_ID == $VPC_ARG ]]; then
        echo "$VPC_ID is an existing VPC"
        tag_vpc_by_name
    else
        echo "$VPC_ARG is not an existing VPC, exiting" && exit
    fi
else
    VPC_NAME=$VPC_ARG
    echo "VPC argument is a name, creating with name tags $VPC_NAME"
    create_vpc
    tag_vpc_by_name
    create_igw
fi

if [[ $SUBNET_ARG == $SUBNET_ID_PATTERN ]]; then
    echo "Subnet argument is an ID, checking Security Group argument"
    if [[ $SG_ARG == $SG_ID_PATTERN ]]; then
        echo "Security Group argument is an ID, checking for an existing VPC"
        
        describe_sg_vpc
        if [[ $SG_VPC_ID == $VPC_ID ]]; then
            echo "$SG_ARG is connected to $SG_VPC_ID"
        else
            echo "$SG_ARG is not connected to $VPC_ID, exiting" && exit
        fi

        describe_subnet_vpc
        if [[ $SUBNET_VPC_ID == $VPC_ID ]]; then
            echo "$SUBNET_ARG is connected to $SUBNET_VPC_ID"
        else
            echo "$SUBNET_ARG is not a part of $VPC_ID, exiting" && exit
        fi

    elif [[ $SG_ARG =~ $SG_PORT_PATTERN ]]; then
        echo "Security Group argument is a port, fetching VPC ID from Subnet"
        describe_vpc
        parse_ports
        describe_subnet_vpc
        if [ -z $SUBNET_VPC_ID ]; then
            echo "No VPC available for $SUBNET_ARG, exiting" && exit
        else 
            create_sg_in_vpc
        fi
    else
        "Unexpected Security Group argument, exiting" && exit
    fi
elif [ $SUBNET_ARG == "public" ]; then
    if [[ $SG_ARG == $SG_ID_PATTERN ]]; then
        describe_sg_vpc
        create_public_subnet
        create_rt
    elif [[ $SG_ARG =~ $SG_PORT_PATTERN ]]; then
        parse_ports
        create_public_subnet
        create_rt
        describe_subnet_vpc
        create_sg_in_vpc
        echo "$SG_ID created and tagged"
    else
        echo "Unexpected Security Group argument, exiting" && exit
    fi
elif [ $SUBNET_ARG == "private" ]; then
    if [[ $SG_ARG == $SG_ID_PATTERN ]]; then
        describe_sg_vpc
        create_private_subnet
        create_rt
    elif [[ $SG_ARG =~ $SG_PORT_PATTERN ]]; then
        parse_ports        
        create_private_subnet
        create_rt
        describe_subnet_vpc
        create_sg_in_vpc
    fi
fi

if [[ $INSTANCE_IMAGE_ID == $INSTANCE_IMAGE_ID_PATTERN ]]; then
    echo "creating instance with image $INSTANCE_IMAGE_ID"
    create_instance
    if [ -z "$INSTANCE_ID" ]; then
        echo "Instance not created" && exit
    fi
else
    echo "Invalid Instance Image ID argument, exiting" && exit
fi

if [[ $SUBNET_ARG == "public" ]]; then
        echo "Instance $INSTANCE_ID created in a public $SUBNET_ID with IP address $PUBLIC_IP"
else
    echo "Instance $INSTANCE_ID created in private subnet $SUBNET_ID"
fi
