#!/bin/bash

RUNS=25

for i in `seq $RUNS`; do
  START=`date +%s.%N`
  wget -q http://192.168.100.1/1048576.bin
  END=`date +%s.%N`
  eval R$i=`echo $END - $START | bc | sed "s/.\{6\}$//"`
  rm 1048576.bin;
done


RS=0
for i in `seq $RUNS`; do
  RS=$(eval echo \$R$i + $RS | bc)
done

echo $RS
echo $(echo "scale=2; $RS / $RUNS" | bc)
