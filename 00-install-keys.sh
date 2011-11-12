#!/bin/bash

. servers
. clients

for HOST in $SERVERS
do
 ssh-copy-id root@$HOST
done

for HOST in $CLIENTS
do
 ssh-copy-id rumith@$HOST
done
