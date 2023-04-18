#!/bin/bash

create_vpc ()
{
    VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.{VpcId:VpcId}' --output text)
    if [ -z "$VPC_ID" ]; then
        echo "VPC ID is empty"
       	exit 1
    else
        aws ec2 create-tags --resources $VPC_ID --tags Key=DeleteMe,Value=Yes
        echo "$VPC_ID created and tagged"
    fi
}
create_igw() {
    IGW_ID=$(aws ec2 create-internet-gateway --query InternetGateway.InternetGatewayId --output text)
    if [ -z "$IGW_ID" ]; then
        echo "Error creating Internet Gateway!"
        exit 1
    else
    	aws ec2 create-tags --resources "$IGW_ID" --tags Key=DeleteMe,Value=Yes
 	echo "$IGW_ID created and tagged"
     	aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID
        echo "$IGW_ID attached to $VPC_ID"
    fi
}
create_rt ()
{
    RT_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID  --query 'RouteTable.{RouteTableId:RouteTableId}' --output text)
    if [ -z "$RT_ID" ]; then
        echo "Error creating Route Table!"
	exit 1
    else
        aws ec2 create-tags --resources $RT_ID --tags Key=DeleteMe,Value=Yes
        echo "$RT_ID created and tagged"
        aws ec2 associate-route-table  --route-table-id $RT_ID --subnet-id $SUBNET_ID --output text >> /dev/null
        echo "routing table associated"
        aws ec2 create-route --route-table-id $RT_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $IGW_ID --output text >> /dev/null
        echo "route created"
    fi
}

delete_rt ()
{
	RT_ID=$(aws ec2 describe-route-tables --filters "Name=tag:DeleteMe,Values=Yes" --query 'RouteTables[0].RouteTableId' --output text)
	aws ec2 delete-route-table --route-table-id "$RT_ID"
 	 if [ $? -eq 0 ]; then
    	    echo "Route table $RT_ID deleted"
         else
                echo "Error deleting RT"
  fi
}

delete_igw ()
{
	 IGW_ID=$(aws ec2 describe-internet-gateways --filters "Name=tag:DeleteMe,Values=Yes"  --query 'InternetGateways[*].{InternetGatewayId:InternetGatewayId}' --output text)
	 VPC_ID=$(aws ec2 describe-internet-gateways --internet-gateway-id "$IGW_ID" --query 'InternetGateways[].Attachments[].VpcId' --output text)
 	 aws ec2 detach-internet-gateway --internet-gateway-id "$IGW_ID" --vpc-id "$VPC_ID"
  	 echo "Internet gateway $IGW_ID detached from VPC $VPC_ID"
  	 aws ec2 delete-internet-gateway --internet-gateway-id "$IGW_ID"
  	 if [ $? -eq 0 ]; then
    	        echo "Internet gateway $IGW_ID deleted"
         else
                echo "Error deleting IGW"
  fi
}
delete_vpc()
{
	 VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:DeleteMe,Values=Yes" --query 'Vpcs[0].VpcId' --output text)
  aws ec2 delete-vpc --vpc-id "$VPC_ID"
  if [ $? -eq 0 ]; then
    echo "VPC $VPC_ID deleted"
        else
                echo "Error deleting VPC"
  fi
}
