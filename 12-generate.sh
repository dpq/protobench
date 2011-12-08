#!/bin/bash

. sizes.sh

for SIZE in $SIZES; do
  echo $SIZE
  ./mkrandom.sh $SIZE
done
