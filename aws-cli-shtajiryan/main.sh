#!/bin/bash

source ./utils/vpc.sh
source ./utils/instance.sh

case ${1} in

create)
    create_vpc

    if [ -z "$VPC_ID" ]; then
        echo "Won't create the rest of resources as VPC ID is empty" && exit
    else

    create_subnet
    fi

    if [ -z "$SUBNET_ID" ]; then
        echo "Won't create the rest of resources as Subnet ID is empty" && exit
    else

    create_igw
    fi

    if [ -z "$IGW_ID" ]; then
        echo "Won't create the rest of resources as Internet Gateway ID is empty" && exit
    else

    create_rt
    fi

    if [ -z "$RT_ID" ]; then
        echo "Won't create the rest of resources as Route Table ID is empty" && exit

    else
        echo "All VPC resources created!"

    create_sg
    fi

    if [ -z "$SG_ID" ]; then
        echo "Won't create an instance as Security Group ID is empty" && exit
    else

    KEY_PAIR=shtajiryan

    create_instance
    fi

    if [ -z "$INSTANCE_ID" ]; then
        echo "Instance not created" && exit
    else
        echo "Instance with IP address $PUBLIC_IP created!"
    fi

;;
delete)
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
;;
esac
