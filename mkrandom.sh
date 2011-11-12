#!/bin/bash

if [[ $# > 0 ]]
then
  SIZE=$1
else
  echo "Usage: ./mkrandom.sh SIZE [..] (in megabytes)"
  exit
fi

echo "Generating file $SIZE.bin..."

#Generate file N Mb long by dd if=/dev/urandom
dd if=/dev/urandom of=$SIZE.bin bs=1048576 count=$SIZE 2> /dev/null
