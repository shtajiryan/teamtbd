# teamtbd

'regex' folder contains a script to check if ips in 'ip-list.txt' are valid or no.

ec2.sh takes 5 arguments:

1. name or id of vpc
2. id, private, public for subnet
3. id, ports separated by ":" for security group
4. instance image id
5. key pair name

'utils' folder contains all necessary resource creation and deletion (cleanup.sh) files with corresponding functions.