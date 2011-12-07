#!/bin/bash
. config.sh
. sizes.sh
. stats.sh

for SIZE in $SIZES; do
  for i in `seq $REPLICATION`; do
    eval R$i=`./mktorrent.sh $SIZE.bin`
    #echo $TIME
    #if [[ ${TIME:0:1} == '.' ]]; then
    #  TIME=0$TIME
    #fi
    #echo $TIME
    #eval R$i=$TIME
    #TIME=`echo $TIME + $( ./mktorrent.sh $SIZE.bin ) | bc`
  done
  #TIME=`echo "scale=3; $TIME / $REPLICATION" | bc`
  #if [[ ${TIME:0:1} == '.' ]]
  #then
  # TIME=0$TIME
  #fi
  echo $SIZE Mb
  stats
done
