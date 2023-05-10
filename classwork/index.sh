#!bin/bash

# create AMI NGINX
cd ./packer
export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2
packer build index.json
cd ../

# print created AMI ID
AMI_ID=$(jq -r '.builds[-1].artifact_id' ./packer/manifest.json | cut -d ":" -f2)
echo $AMI_ID

#create EC2 Instance
cd ./terraform/ec2
# terraform init -upgrade
terraform apply -var="access_key=$1" \
    -var="secret_key=$2" \
    -var="ami_id=$AMI_ID" \
    -var-file=variables.tfvars
cd ../../