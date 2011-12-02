#!/bin/bash

. servers.sh
. clients.sh

for HOST in $SERVERS
do
 ssh-copy-id root@$HOST
done

for HOST in $CLIENTS
do
 ssh-copy-id rumith@$HOST
done
