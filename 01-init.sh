#!/bin/bash
# Prerequisites: bash

. servers
. clients
. config

#sudo apt-get update && apt-get -y install bittorrent openssh-client

for HOST in $SERVERS; do
  #ssh root@$HOST apt-get update
  #ssh root@$HOST apt-get -y install nginx vsftpd wget bittorrent
  #ssh root@$HOST wget $DATAHOST/1024.bin.torrent
  #ssh root@$HOST wget -bqc $DATAHOST/1024.bin
done


#for HOST in $CLIENTS; do
  #ssh $HOST
#done
