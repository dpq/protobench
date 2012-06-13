#!/bin/bash
echo $1 $2 $3 $4
START=`date +%s.%N`
cd /home/protobench/
echo Downloading
wget -q http://$4/1024.bin
echo Complete
END=`date +%s.%N`
mkdir -p /home/protobench/$1-$2/
eval R$i=`echo 8*1024/\($END - $START\) | bc | sed "s/.\{6\}$//"`
echo $(eval echo \$R$i)  > /home/protobench/$1-$2/$3
cat /home/protobench/$1-$2/$3
rm 1024.bin
