#!/bin/bash

. servers.sh
. clients.sh
. config.sh

sudo apt-get update && sudo apt-get -y install bittorrent openssh-client

for HOST in $SERVERS; do
  ssh -i ~/.ssh/aws.pem root@$HOST mkfs.ext3 /dev/xvdf1
  ssh -i ~/.ssh/aws.pem root@$HOST mkdir /home/protobench
  ssh -i ~/.ssh/aws.pem root@$HOST echo "/dev/xvdf1 /home/protobench ext3 defaults 0 0" >> /etc/fstab
  ssh -i ~/.ssh/aws.pem root@$HOST mount /home/protobench
  ssh -i ~/.ssh/aws.pem root@$HOST apt-get update
  ssh -i ~/.ssh/aws.pem root@$HOST apt-get -y install nginx vsftpd wget bittorrent globus-gridftp-server-progs libglobus-gridftp-server-dev
  ssh -i ~/.ssh/aws.pem root@$HOST wget $DATAHOST/1024.bin.torrent -O /home/protobench/1024.bin.torrent
  ssh -i ~/.ssh/aws.pem root@$HOST wget -bq $DATAHOST/1024.bin -o log -O /home/protobench/1024.bin
done

ssh -i /.ssh/aws.pem root@$PROXY apt-get -y install haproxy pen
ssh -i /.ssh/aws.pem root@$PROXY pen 21 -l pen.log -p pen.pid am0:21 am1:21 am2:21 am3:21 am4:21

# TODO compile the udt testing program
#for HOST in $CLIENTS; do
#  ssh $HOST sudo apt-get install wget bittorrent
#  TODO copy udt tester, install wget and gridftp client
#done
