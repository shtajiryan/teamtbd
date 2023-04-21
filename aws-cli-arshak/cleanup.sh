#!bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/utils"

keyName="virginia"
for file in $SCRIPT_DIR/*.sh; do
    source "$file"
done

# Input parameters
TAG_KEY="tbd"
TAG_VALUE="true"
echo "CleanUp is Started..."
# Fetch all instances with the specified tag
describeInstance "$TAG_KEY" "$TAG_VALUE"
echo "$instanceIds"
deleteInstance "$instanceIds"

describeSecurityGroup "$TAG_KEY" "$TAG_VALUE"
echo "$sgId"
deleteSecurityGroup "$sgId"

describeRouteTable "$TAG_KEY" "$TAG_VALUE"
echo "$rtIds"
deleteRouteTable "$rtIds"

describeSubnet "$TAG_KEY" "$TAG_VALUE"
echo "$sbIds"
deleteSubnet "$sbIds"

describeIGW "$TAG_KEY" "$TAG_VALUE"
echo "$igwIds"
deleteIGW "$igwIds"

describeVPC "$TAG_KEY" "$TAG_VALUE"
echo "$vpcIds"
deleteVpc "$vpcIds"

# Print the results
echo "CleanUp is Finished"