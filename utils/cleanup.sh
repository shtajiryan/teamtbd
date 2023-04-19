#!/bin/bash

source instance.sh
source subnet.sh
source vpc.sh

delete_instance
instance_state

while [ "$INSTANCE_STATE" != 48 ]; do
    echo "Instance not in terminated state yet, waiting 10 seconds"
    sleep 10s

    instance_state
done

delete_sg

if [ -n "$SG_ID" ]; then
    echo "$SG_ID deleted"
else
    echo "Security Group not deleted" && exit
fi

delete_subnet

if [ -n "$SUBNET_ID" ]; then
    echo "$SUBNET_ID deleted"
else
    echo "Subnet not deleted" && exit
fi

delete_rt

if [ -n "$RT_ID" ]; then
    echo "$RT_ID deleted"
else
    echo "Route Table not deleted" && exit
fi

delete_igw

if [ -n "$IGW_ID" ]; then
    echo "$IGW_ID deleted"
else
    echo "Internet Gateway not deleted" && exit
fi

delete_vpc

if [ -n "$VPC_ID" ]; then
    echo "$VPC_ID deleted"
else
    echo "VPC not deleted" && exit
fi
