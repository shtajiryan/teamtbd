#!/bin/bash

source utils/vpc.sh
source utils/instance.sh
source utils/subnet.sh
source utils/portparse.sh

VPC_ARG="$1"
SUBNET_ARG="$2"
SG_ARG="$3"
INSTANCE_IMAGE_ID="$4"
KEY_PAIR="$5"

parse_ports
