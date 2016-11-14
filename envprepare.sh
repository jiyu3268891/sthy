#!/bin/bash
envlist=`cat /apps/adf/install/env.txt`
Myid=`who am i| awk '{print$1}'`


for tmp in $envlist
do
scp -r /apps/adf/jdk1.8.0_60 $tmp:/apps/adf
scp -r /apps/adf/Pivotal_GemFire_820_b17919_Linux $tmp:/apps/adf
scp /home/$Myid/.bashrc $tmp:/home/$Myid
done

for tmp in $envlist
do
    ssh $tmp "source /home/$Myid/.bashrc"	
done
