#!bin/bash

function createRouteTable() {
    routeTableName="$1 Route Table"
    vpcId=$2
    gatewayId=$3
    subnetId=$4
    destinationCidrBlock=$5

    routeTableId=0

    #create route table for vpc
    route_table_response=$(aws ec2 create-route-table \
    --vpc-id "$vpcId" \
    --output json)
    routeTableId=$(echo -e "$route_table_response" |  /usr/bin/jq '.RouteTable.RouteTableId' | tr -d '"')

    #name the route table
    aws ec2 create-tags \
    --resources "$routeTableId" \
    --tags Key=Name,Value="$routeTableName"

    #add tbd tag
    aws ec2 create-tags \
    --resources "$routeTableId" \
    --tags Key=tbd,Value="true"

    #add route for the internet gateway
    route_response=$(aws ec2 create-route \
    --route-table-id "$routeTableId" \
    --destination-cidr-block "$destinationCidrBlock" \
    --gateway-id "$gatewayId")

    #add route to subnet
    associate_response=$(aws ec2 associate-route-table \
        --subnet-id "$subnetId" \
        --route-table-id "$routeTableId"
    )
}

function describeRouteTable() {
    TAG_KEY=$1
    TAG_VALUE=$2
    rtIds=$(
        aws ec2 describe-route-tables \
        --filters "Name=tag:${TAG_KEY},Values=${TAG_VALUE}" \
        --query "RouteTables[].RouteTableId" \
        --output text
    )
}

function deleteRouteTable() {
    ids=$1
    for id in $ids;
    do
        route_table_response=$(aws ec2 describe-route-tables \
            --route-table-ids $id \
            --output json \
        )
        routeTableAssocId=$(echo -e "$route_table_response" |  /usr/bin/jq '.RouteTables[0].Associations[0].RouteTableAssociationId' | tr -d '"')

        aws ec2 disassociate-route-table --association-id $routeTableAssocId
        aws ec2 delete-route-table --route-table-id "$id"
    done
}