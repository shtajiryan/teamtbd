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

        aws ec2 authorize-security-group-ingress \
            --group-id $SG_ID \
            --protocol tcp \
            --port 22 \
            --cidr 0.0.0.0/0 \
            --output text >> /dev/null

        aws ec2 authorize-security-group-ingress \
            --group-id $SG_ID \
            --protocol tcp \
            --port 80 \
            --cidr 0.0.0.0/0 \
            --output text >> /dev/null

        echo "SSH allowed for $SG_ID"
        echo "Port 80 opened for all on $SG_ID"
    fi
}

create_instance ()
{
    INSTANCE_ID=$(aws ec2 run-instances \
            --image-id ami-007855ac798b5175e \
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
