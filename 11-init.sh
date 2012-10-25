#!/bin/bash

. servers.sh
. clients.sh
. config.sh

sudo apt-get update && sudo apt-get -y install bittorrent openssh-client wget build-essential

wget http://ignum.dl.sourceforge.net/project/udt/udt/4.10/udt.sdk.4.10.tar.gz
a=1
IFS=' ' read -ra HOSTS <<< "$SERVERS"
for i in "${HOSTS[@]}"; do
  ssh p$i mkfs.ext3 /dev/xvdf1
  ssh p$i mkdir /home/protobench
  ssh p$i echo "/dev/xvdf1 /home/protobench ext3 defaults 0 0" >> /etc/fstab
  ssh p$i mount /home/protobench
  ssh p$i apt-get update
  ssh p$i apt-get -y install nginx vsftpd wget bittorrent globus-gridftp-server-progs libglobus-gridftp-server-dev
  ssh p$i wget $DATAHOST/1024.bin.torrent -O /home/protobench/1024.bin.torrent
  ssh p$i wget -bq $DATAHOST/1024.bin -o log -O /home/protobench/1024.bin
  scp udt.sdk.4.10.tar.gz p$i:/home/protobench
  ssh p$i 'cd /home/protobench && tar -xzf udt.sdk.4.10.tar.gz && cd udt4/src && make && cd ../app && make'
  ssh p$i 'wget http://www.globus.org/ftppub/gt5/5.2/5.2.0/installers/repo/globus-repository-squeeze_0.0.2_all.deb && dpkg -i globus-repository-squeeze_0.0.2_all.deb && aptitude update && tasksel install globus-gridftp && aptitude -y upgrade && aptitude -y install globus-simple-ca'
  ssh p$i ln -s /home/protobench/ /var/www
  ssh p$i invoke-rc.d nginx start
done

# FIXME upload the correct ips for pen
ssh pp apt-get -y install haproxy pen
ssh pp pen 21 -l pen.log -p pen.pid am0:21 am1:21 am2:21 am3:21 am4:21

for HOST in $CLIENTS; do
  ssh $HOST sudo apt-get install wget bittorrent build-essential
  ssh $HOST 'wget http://www.globus.org/ftppub/gt5/5.2/5.2.0/installers/repo/globus-repository-squeeze_0.0.2_all.deb && sudo dpkg -i globus-repository-squeeze_0.0.2_all.deb && sudo aptitude update && sudo tasksel install globus-gridftp && sudo aptitude -y upgrade && sudo aptitude -y install globus-simple-ca'
  ssh $HOST sudo mkdir /home/protobench
  ssh $HOST sudo chown -R rumith:rumith /home/protobench
  scp udt.sdk.4.10.tar.gz $HOST:/home/protobench
  ssh $HOST 'cd /home/protobench && tar -xzf udt.sdk.4.10.tar.gz && cd udt4/src && make && cd ../app && make'
done
