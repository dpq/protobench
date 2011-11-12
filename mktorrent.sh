#!/bin/bash

. config

if [[ $# > 0 ]]
then
  FILE=$1
else
  echo "Usage: ./mktorrent.sh FILE"
  exit
fi

START=`date +%s.%N`

btmakemetafile $FILE $TRACKER > /dev/null

END=`date +%s.%N`
TIME=`echo $END - $START | bc`
if [[ ${TIME:0:1} == '.' ]]
then
 TIME=0$TIME
fi

echo $TIME
