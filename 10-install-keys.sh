#!/bin/bash

. servers.sh
. clients.sh

for HOST in $SERVERS
do
 ssh-copy-id root@$HOST
done

ssh-copy-id root@$PROXY

# I already have the necessary keys installed to the hosts used as clients
