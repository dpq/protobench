#!/bin/bash

stats() {
  RS=0
  for i in `seq $RUNS`; do
    RS=$(eval echo \$R$i + $RS | bc)
  done

  SIGMA=0
  for i in `seq $RUNS`; do
    delta=$(eval echo \$R$i - $RS)
    SIGMA=`echo "scale=2; $SIGMA + $delta^2"`
  done

  echo Mean $(echo "scale=2; $RUNS*1073.741824*8 / $RS " | bc)
  echo Sigma $(echo "scale=2; sqrt($SIGMA/$RUNS) " | bc)
}
