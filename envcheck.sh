#!/bin/bash
envlist=`cat /apps/adf/install/env.txt`
rm -rf /apps/adf/install/envcheck.log
for tmp in $envlist
do
    ssh $tmp "mkdir -p /apps/adf/install"	
done
for tmp in $envlist
do
scp /apps/adf/install/everymembercheck.sh $tmp:/apps/adf/install
done
for tmp in $envlist
do
    declare -l HOSTNAME=$tmp
    ssh $tmp "sh /apps/adf/install/everymembercheck.sh"	>> /apps/adf/install/envcheck.log
done

