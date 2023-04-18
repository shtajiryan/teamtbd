#!/bin/bash

parse_ports ()
{
    ports="left:right"
    IFS=":" read -ra parts <<< "$SG_ARG"
    left="${parts[0]}"
    right="${parts[1]}"
}