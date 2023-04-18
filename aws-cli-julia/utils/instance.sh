#!/bin/bash

create_sg() 
{
	SG_ID=$(aws ec2 create-security-group --group-name my-sg --description "My security group" --vpc-id "${VPC_ID}" --output text)
    if [ -z "$SG_ID" ]; then
        echo "Error creating Security Group!"
        exit 1
        else
            echo "Security group created!!"
    fi
    aws ec2 create-tags --resources "$SG_ID" --tags Key=DeleteMe,Value=Yes
    aws ec2 authorize-security-group-ingress --group-id "${SG_ID}" --protocol tcp --port 22 --cidr 0.0.0.0/0
    aws ec2 authorize-security-group-ingress --group-id "${SG_ID}" --protocol tcp --port 80 --cidr 0.0.0.0/0
	echo "Rules created"
}

create_instance ()
{
	INSTANCE_ID=$(aws ec2 run-instances --image-id ami-0557a15b87f6559cf --instance-type t2.micro --key-name "${KEY}" --security-group-ids "${SG_ID}" --subnet-id "${SUBNET_ID}" --query 'Instances[0].InstanceId' --output text)
	 if [ -z "$INSTANCE_ID" ]; then
            echo "Instance ID is empty, no instance created"
	    exit 1
    else
	    aws ec2 create-tags --resources $INSTANCE_ID --tags Key=DeleteMe,Value=Yes 
	    echo "$INSTANCE_ID created and tagged"
    fi

    PUBLIC_IP=$(aws ec2 describe-instances  --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].[PublicIpAddress]' --output text)
}

delete_instance ()
{
	INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" "Name=tag:DeleteMe,Values=Yes" --query 'Reservations[*].Instances[*].[InstanceId]'  --output text)
	if [ -z "$INSTANCE_ID" ]; then
        echo "Instance ID is empty, can't delete"
	exit 1
    else
	    aws ec2 stop-instances --instance-id $INSTANCE_ID --output text
	   echo "$INSTANCE_ID stopped"

	    aws ec2 terminate-instances --instance-id $INSTANCE_ID  --query 'Reservations[*].Instances[*].[InstanceId]' --output text
	    echo "$INSTANCE_ID terminated"
	  fi
}

delete_sg ()
{
	SG_ID=$(aws ec2 describe-security-groups --filters "Name=tag:DeleteMe,Values=Yes" --query 'SecurityGroups[*].GroupId' --output text)
	aws ec2 delete-security-group --group-id $SG_ID
}


