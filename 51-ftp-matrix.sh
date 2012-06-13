#!/bin/bash

. stats.sh
. config.sh
. servers.sh
. clients.sh

N=1 # must match haproxy's settings - number of servers. TODO this is not automated yet, unfortunately :(
M=4 # number of clients to run. No feedback system, so TODO this is not automated yet as well :(

echo Run started
for i in `seq $N`; do
  for m in `seq $M`; do
    HOST=$(echo $CLIENTS | awk "{ print \$$m }")
    echo $HOST
    ssh $HOST "nohup /home/protobench/510-ftp-matrix-element.sh $N $M $i $PROXY </dev/null >/dev/null 2>&1 &"
  done
done
echo Run launch complete!

#for n in `seq 1`; do
#  for m in `seq 1`; do
#    for i in `seq 1`; do
#      echo Run number $i of $n x $m
#      HOST=$(echo $CLIENTS | awk "{ print \$$i }")
#      echo $HOST
#      ssh $HOST "START=`date +%s.%N` && wget ftp://anonymous@$PROXY/1024.bin && END=`date +%s.%N`" # && mkdir -p /home/protobench/$n-$m/ ; eval R$i=`echo 8*1024/\($END - $START\) | bc | sed \"s/.\{6\}$//\"` && echo eval \$R$i > /home/protobench/$n-$m/$i && rm 1024.bin"
#    done
#  done
#done

#for i in `seq $REPLICATION`; do
#  START=`date +%s.%N`
#  wget -q ftp://anonymous@213.131.1.8/1024.bin
#  END=`date +%s.%N`
#  eval R$i=`echo 8*1024/\($END - $START\) | bc | sed "s/.\{6\}$//"`
#  rm 1024.bin
#done

#stats


#!/bin/bash

#RUNS=25

#for i in `seq $RUNS`; do
#  START=`date +%s.%N`
#  wget -q ftp://anonymous@192.168.100.1/1024.bin
#  END=`date +%s.%N`
#  eval R$i=`echo $END - $START | bc | sed "s/.\{6\}$//"`
#  rm 1024.bin;
#done


#RS=0
#for i in `seq $RUNS`; do
#  RS=$(eval echo \$R$i + $RS | bc)
#done

#echo $RS
#echo $(echo "scale=2; $RS / $RUNS" | bc)
