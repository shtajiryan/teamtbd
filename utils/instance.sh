#!/bin/bash

create_sg ()
{
    SG_ID=$(aws ec2 create-security-group \
	    --group-name acatest \
	    --description "aca test security group" \
        --vpc-id $VPC_ID \
        --query 'GroupId' \
        --output text)

    if [ -z "$SG_ID" ]; then
        echo "Security Group ID is empty, exiting..." && return 1  
    else
        aws ec2 create-tags \
            --resources $SG_ID \
            --tags Key=DeleteMe,Value=Yes

        echo "$SG_ID created and tagged"
    fi
}

create_sg_in_vpc ()
{
    SG_ID=$(aws ec2 create-security-group \
        --group-name acatest \
        --description "aca test security group" \
        --vpc-id $SUBNET_VPC_ID \
        --query 'GroupId' \
        --output text)

    aws ec2 create-tags \
        --resources $SG_ID \
        --tags Key=DeleteMe,Value=Yes

    echo "$SG_ID created and tagged"

    IFS=":" read -ra PortsArray <<< "$SG_ARG"
    total_ports=${#PortsArray[@]}
    echo "$total_ports"
    for i in $(seq 0 $(($total_ports - 1))); do
        port=${PortsArray[$i]}
        aws ec2 authorize-security-group-ingress \
            --group-id "$SG_ID" \
            --protocol tcp \
            --port $port \
            --cidr 0.0.0.0/0 \
            --output text >> /dev/null
        echo "Port $port opened for all" 
    done
}

create_instance ()
{
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $INSTANCE_IMAGE_ID \
        --instance-type t2.micro \
        --key-name $KEY_PAIR \
        --monitoring "Enabled=false" \
        --security-group-ids $SG_ID \
        --subnet-id $SUBNET_ID \
        --private-ip-address 10.0.1.10 \
        --query 'Instances[0].InstanceId' \
        --output text)
    if [ -z "$INSTANCE_ID" ]; then
        echo "Instance ID is empty, no instance created" && return 1
    else
        aws ec2 create-tags \
            --resources $INSTANCE_ID \
            --tags Key=DeleteMe,Value=Yes
        echo "$INSTANCE_ID created and tagged"
    fi

    PUBLIC_IP=$(aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[*].Instances[*].[PublicIpAddress]' \
            --output text)
}

describe_sg ()
{
    SG_ID=$(aws ec2 describe-security-groups \
        --filters "Name=tag:DeleteMe,Values=Yes" \
        --query "SecurityGroups[*].GroupId" \
        --output text)
}

describe_sg_vpc ()
{
    SG_VPC_ID=$(aws ec2 describe-security-groups \
        --group-ids $SG_ID \
        --filters "Name=tag:DeleteMe,Values=Yes" \
        --query "SecurityGroups[*].VpcId" \
        --output text)
}

delete_instance ()
{
    INSTANCE_ID=$(aws ec2 describe-instances \
	        --filters "Name=instance-state-name,Values=running" "Name=tag:DeleteMe,Values=Yes" \
	        --query 'Reservations[*].Instances[*].[InstanceId]' \
	        --output text)
    
    if [ -z "$INSTANCE_ID" ]; then
        echo "Instance ID is empty, can't delete" && return 1
    else
        aws ec2 stop-instances \
            --instance-id $INSTANCE_ID \
            --output text >> /dev/null

        echo "$INSTANCE_ID stopped"

        aws ec2 terminate-instances \
            --instance-id $INSTANCE_ID \
            --query 'Reservations[*].Instances[*].[InstanceId]' \
            --output text >> /dev/null

    echo "$INSTANCE_ID terminated"
    fi

    #aws ec2 wait instance-terminated --instance-ids "$i"
}

delete_sg ()
{
    SG_ID=$(aws ec2 describe-security-groups \
        --filters "Name=tag:DeleteMe,Values=Yes" \
        --query 'SecurityGroups[*].GroupId' \
        --output text)

    aws ec2 delete-security-group \
        --group-id $SG_ID
}

instance_state ()
{
    INSTANCE_STATE=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations[*].Instances[*].State.Code' \
        --output text)
}
