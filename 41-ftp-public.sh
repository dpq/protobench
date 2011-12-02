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

#echo $(echo "scale=2; $RUNS*1073.741824*8 / $RS" | bc)
SIGMA=0
for i in `seq $RUNS`; do
  delta=$(eval echo \$R$i - $RS)
  SIGMA=`echo "scale=2; $SIGMA + $delta^2"`
done

echo Mean $(echo "scale=2; $RUNS*1073.741824*8 / $RS " | bc)
echo Sigma $(echo "scale=2; sqrt($SIGMA/$RUNS) " | bc)

