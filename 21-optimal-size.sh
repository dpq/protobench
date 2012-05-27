#!/bin/bash
. config.sh
. sizes.sh
. stats.sh

for SIZE in $SIZES; do
  for i in `seq $REPLICATION`; do
    eval R$i=`./mktorrent.sh $SIZE.bin`
  done
  echo $SIZE Mb
  stats
done
