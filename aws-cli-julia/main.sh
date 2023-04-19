#!/bin/bash

source ./utils/create_subnet.sh
source ./utils/create_vpc.sh
source ./utils/instance.sh

VPC_ARG="$1"
SUBNET_ARG="$2"
SG_ARG="$3"
SUBNET_ID_regex='^subnet-[0-9a-f]+$'
SG_ID_regex='^sg-[0-9a-f]+$'
SG_Port_regex='^[\d]+$'
VPC_ID_regex='^vpc-[0-9a-f]+$'

if [[$VPC_ARG == $VPC_ID_regex]]; then
	echo "VPC_ARG is an ID"
	describe_vpc
	if [[ $VPC_ID == $VPC_ARG ]]; then
		echo "$VPC_ID is an existing VPC"
	else
		echo "Error,$VPC_ARG is not an existing VPC"
	create_igw
	fi
if [[$SUBNET_ARG == $SUBNET_ID_regex ]]; then
	echo "Subnet_ARG is an ID"
if [[$SG_ARG == $SG_ID_regex]]; then 
	echo "SG_ARG is an ID"
	
	describe_sg_vpc
	


