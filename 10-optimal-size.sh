#!/bin/bash
. config
. sizes

for SIZE in $SIZES; do
  TIME=0
  for i in `seq $REPLICATION`; do
    TIME=`echo $TIME + $( ./mktorrent.sh $SIZE.bin ) | bc`
  done
  if [[ ${TIME:0:1} == '.' ]]
  then
   TIME=0$TIME
  fi
  TIME=`echo "scale=3; $TIME / $REPLICATION" | bc`
  if [[ ${TIME:0:1} == '.' ]]
  then
   TIME=0$TIME
  fi
  echo $SIZE $TIME
done
