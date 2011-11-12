#!/bin/bash

. sizes

for SIZE in $SIZES; do
  echo $SIZE
  ./mkrandom.sh $SIZE
  ./mktorrent.sh $SIZE.bin
done
