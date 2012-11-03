#!/bin/bash

. stats.sh
. config.sh
. servers.sh
. clients.sh

N=1 # must match haproxy's settings - number of servers. TODO this is not automated yet, unfortunately :(
M=1 # number of clients to run. No feedback system, so TODO this is not automated yet as well :(

echo Run started
for i in `seq $N`; do
  for m in `seq $M`; do
    HOST=$(echo $CLIENTS | awk "{ print \$$m }")
    echo $HOST "nohup /home/protobench/520-http-matrix-element.sh $N $M $i $PROXY </dev/null >/dev/null 2>&1 &"
    ssh $HOST "nohup /home/protobench/520-http-matrix-element.sh $N $M $i $PROXY </dev/null >/dev/null 2>&1 &"
  done
done

echo Run launch complete!
