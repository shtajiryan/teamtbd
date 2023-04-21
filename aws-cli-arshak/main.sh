#!bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/utils"

keyName="virginia"
for file in $SCRIPT_DIR/*.sh; do
    source "$file"
done
# source "$SCRIPT_DIR/*.sh"
name=$(echo -e "$1" |  /usr/bin/jq '.name' | tr -d '"')

if [[ -z $name ]]; then
    name="New_Instance"
fi



sub=$(echo -e "$1" |  /usr/bin/jq '.subnet' | tr -d '"')
sg=$(echo -e "$1" |  /usr/bin/jq '.sg' | tr -d '"')
igw=$(echo -e "$1" |  /usr/bin/jq '.igw' | tr -d '"')

pubAvailabilityZone="us-east-1a"
privAvailabilityZone="us-east-1b"

subNetCidrBlock="10.0.1.0/24"
vpcCidrBlock="10.0.0.0/16"
destinationCidrBlock="0.0.0.0/0"

function runForCreateInstance() {
    if [[ $sub ]];
    then
        if [[ $sub =~ ^(subnet-[a-f0-9]{17})$ ]];
        then
            checkSubnetById "$sub"
            if [[ $subnetId && $sg =~ ^(sg-[a-f0-9]{17})$ ]];
            then
                checkSGById "$sg"
                if [[ $groupId ]];
                then
                    getVpcIdBySG_Id "$sg"
                    getVpcInSubnet "$sub"
                    if [ $sgVpcId == $subVpcId ];
                    then
                        vpcId=$sgVpcId
                    else
                        return
                    fi
                else
                    return
                fi
            elif [[ $subnetId && $sg =~ ^([0-9]{2,5}|([0-9]{2,5}(\ [0-9]{2,5}){1,}))$ ]]; #change multiple
            then
                getVpcInSubnet "$subnetId"
                echo "Create Security Group"
                createSecurityGroup "$name" "$sg" "$subVpcId"
            else
                return
            fi
        elif [[ $sub == "priv" || $sub == "pub" ]];
        then
            if [[ $sg =~ ^(sg-[a-f0-9]{17})$ ]];
            then
                getVpcIdBySG_Id "$sg"
                if [[ $sgVpcId ]];
                then
                    vpcId=$sgVpcId
                    if [[ $sub == "priv" ]];
                    then
                        echo "Create Private Subnet"
                        createSubnet "$name" "$privAvailabilityZone" "$vpcId" "private"
                    else
                        echo "Create Public Subnet"
                        createSubnet "$name" "$pubAvailabilityZone" "$vpcId" "public"
                    fi
                else
                    return
                fi
            elif [[ $sg =~ ^([0-9]{2,5}|([0-9]{2,5}(\ [0-9]{2,5}){1,}))$ ]];
            then
                echo "create VPC, Subnet and SecurityGroup."
                createVpc "$name" "$vpcCidrBlock"
                createSubnet "$name" "$pubAvailabilityZone" "$vpcId"
                createSecurityGroup "$name" "$sg" "$vpcId"
            else
                return
            fi
        fi
    else
        createVpc "$name" "$vpcCidrBlock"
        createSubnet "$name" "$pubAvailabilityZone" "$vpcId"
        createSecurityGroup "$name" "80" "$vpcId"
    fi

    #Internet Gateway
    if [[ $igw && $igw =~ ^(igw-[a-f0-9]{17})$ ]];
    then
        getVpcId_IGWById $igw
        if [[ !$igwVpcId || -z $igwVpcId ]];
        then
            gatewayId=$igw
            attachVpc "$igw" "$vpcId"
        fi
    else
        createGatewayAndAttachVpc "$name" "$vpcId"
    fi
    #Route Table
    if [[ $vpcId && $gatewayId && $subnetId ]];
    then
        createRouteTable "$name" "$vpcId" "$gatewayId" "$subnetId" "$destinationCidrBlock"
    fi

    if [[ $groupId && $subnetId && $keyName ]];
    then
        createInstance "$name" "$groupId" "$subnetId" "$keyName"
    fi
    echo $s3_instance
}
runForCreateInstance