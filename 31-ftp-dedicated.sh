#!/bin/bash

. stats.sh
. config.sh

for i in `seq $REPLICATION`; do
  START=`date +%s.%N`
  wget -q ftp://anonymous@192.168.100.1/1024.bin
  END=`date +%s.%N`
  eval R$i=`echo $END - $START | bc | sed "s/.\{6\}$//"`
  rm 1024.bin;
done

stats

#RS=0
#for i in `seq $REPLICATION`; do
#  RS=$(eval echo \$R$i + $RS | bc)
#done

#SIGMA=0
#for i in `seq $REPLICATION`; do
#  delta=$(eval echo \$R$i - $RS)
#  SIGMA=`echo "scale=2; $SIGMA + $delta^2"`
#done

#echo Mean $(echo "scale=2; $REPLICATION*1073.741824*8 / $RS " | bc)
#echo Sigma $(echo "scale=2; sqrt($SIGMA/$REPLICATION) " | bc)
