#!/bin/bash

. servers.sh
. clients.sh
. config.sh

sudo apt-get update && sudo apt-get -y install bittorrent openssh-client wget build-essential

wget http://ignum.dl.sourceforge.net/project/udt/udt/4.10/udt.sdk.4.10.tar.gz

for HOST in $SERVERS; do
  ssh -i ~/.ssh/aws.pem root@$HOST mkfs.ext3 /dev/xvdf1
  ssh -i ~/.ssh/aws.pem root@$HOST mkdir /home/protobench
  ssh -i ~/.ssh/aws.pem root@$HOST echo "/dev/xvdf1 /home/protobench ext3 defaults 0 0" >> /etc/fstab
  ssh -i ~/.ssh/aws.pem root@$HOST mount /home/protobench
  ssh -i ~/.ssh/aws.pem root@$HOST apt-get update
  ssh -i ~/.ssh/aws.pem root@$HOST apt-get -y install nginx vsftpd wget bittorrent globus-gridftp-server-progs libglobus-gridftp-server-dev
  ssh -i ~/.ssh/aws.pem root@$HOST wget $DATAHOST/1024.bin.torrent -O /home/protobench/1024.bin.torrent
  ssh -i ~/.ssh/aws.pem root@$HOST wget -bq $DATAHOST/1024.bin -o log -O /home/protobench/1024.bin
  scp -i ~/.ssh/aws.pem udt.sdk.4.10.tar.gz root@$HOST:/home/protobench
  ssh -i ~/.ssh/aws.pem root@$HOST 'cd /home/protobench && tar -xzf udt.sdk.4.10.tar.gz && cd udt4/src && make && cd ../app && make'
done

ssh -i /.ssh/aws.pem root@$PROXY apt-get -y install haproxy pen
ssh -i /.ssh/aws.pem root@$PROXY pen 21 -l pen.log -p pen.pid am0:21 am1:21 am2:21 am3:21 am4:21

for HOST in $CLIENTS; do
  ssh $HOST sudo apt-get install wget bittorrent build-essential
  ssh $HOST sudo mkdir /home/protobench
  ssh $HOST sudo chown -R rumith:rumith /home/protobench
  scp udt.sdk.4.10.tar.gz $HOST:/home/protobench
  ssh $HOST 'cd /home/protobench && tar -xzf udt.sdk.4.10.tar.gz && cd udt4/src && make && cd ../app && make'
  ssh $HOST sudo ln -s /home/protobench/udt4/src/libudt.so /usr/local/lib
  scp udt4/app/sendfile $HOST:/home/protobench/
done
