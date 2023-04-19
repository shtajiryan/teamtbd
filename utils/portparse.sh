#!/bin/bash

parse_ports ()
{
IFS=':' read -ra parts <<< "$SG_ARG"
	for ((i=0; i<${#parts[@]}; i++)); do
	    PART_NAME="part$(($i+1))"
	    declare "$PART_NAME=${parts[$i]}"
	done
}

for ((i=0; i<${#parts[@]}; i++));
    do PART_NAME="part$(($i+1))"
    echo "$PART_NAME: ${!PART_NAME}"
done


#ports="left:right"
#IFS=":" read -ra parts <<< "$SG_ARG"
#left="${parts[0]}"
#right="${parts[1]}"