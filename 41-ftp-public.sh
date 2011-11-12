#!/bin/bash

RUNS=25

for i in `seq $RUNS`; do
  START=`date +%s.%N`
  wget -q ftp://anonymous@213.131.1.8/1024.bin
  END=`date +%s.%N`
  eval R$i=`echo $END - $START | bc | sed "s/.\{6\}$//"`
  rm 1024.bin;
done


RS=0
for i in `seq $RUNS`; do
  RS=$(eval echo \$R$i + $RS | bc)
done

echo $RS
echo $(echo "scale=2; $RS / $RUNS" | bc)
