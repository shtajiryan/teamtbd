#!/bin/bash

parse_ports ()
{
    IFS=":" read -ra PortsArray <<< "$SG_ARG"
    for i in "${!PortsArray[@]}"; do
        ports="port$((i+1))"
        declare "$ports=${PortsArray[i]}"
        echo "${!ports}"
    done  
}