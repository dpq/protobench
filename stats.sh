#!/bin/bash

stats() {
  RS=0
  for i in `seq $REPLICATION`; do
    RS=$(eval echo \$R$i + $RS)
  done

  RS=`echo "scale=4; ($RS)/$REPLICATION" | bc`
  SIGMA=0
  for i in `seq $REPLICATION`; do
    delta=$(eval echo \$R$i - $RS )
    SIGMA=`echo "scale=4; $SIGMA + ($delta)^2" | bc`
  done

  echo $(echo "scale=4; $RS" | bc | awk '{printf "%f", $0}')  $(echo "scale=4; sqrt($SIGMA/$REPLICATION) " | bc | awk '{printf "%f", $0}')
}
