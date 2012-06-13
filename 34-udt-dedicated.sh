#!/bin/bash

. stats.sh
. config.sh

for i in `seq $REPLICATION`; do
  START=`date +%s.%N`
  LD_LIBRARY_PATH=/home/protobench/udt4/src /home/protobench/udt4/app/recvfile 192.168.100.1 9000 /var/www/1024.bin 1024.bin
  END=`date +%s.%N`
  eval R$i=`echo 8*1024/\($END - $START\) | bc | sed "s/.\{6\}$//"`
  rm 1024.bin
done

stats
