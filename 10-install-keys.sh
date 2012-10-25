#!/bin/bash

. servers.sh
. clients.sh

for HOST in $SERVERS
do
 ssh-copy-id root@$HOST
done

ssh-copy-id root@$PROXY

# I already have the necessary keys installed to the hosts used as clients

a=1
IFS=' ' read -ra HOSTS <<< "$SERVERS"
for i in "${HOSTS[@]}"; do
	echo -e "\nHost p$a\n  User root\n  IdentityFile ~/.ssh/aws.pem\n  Hostname $i" >> ~/.ssh/config
	a=$(($a+1))
done

echo -e "\nHost pp\n  User root\n  IdentityFile ~/.ssh/aws.pem\n  Hostname $PROXY\n  UserKnownHostsFile /dev/null\n  StrictHostKeyChecking no" >> ~/.ssh/config
