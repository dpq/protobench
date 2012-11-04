#!/bin/bash
START=`date +%s.%N`
cd /home/protobench/
echo Downloading
wget -q http://$1/1024.bin
echo Complete
END=`date +%s.%N`
eval R=`echo 8*1024/\($END - $START\) | bc | sed "s/.\{6\}$//"`
wget -q "http://dp.io:9090/done?expid=$2&runid=$3&bw=$R"
rm 1024.bin
