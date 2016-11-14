#!/bin/bash
echo "##############################################################"
echo "`hostname`：Env logs are as followes"
echo ""
echo "ulimit -n:`ulimit -n`" 
echo ""
echo "ulimit -u:`ulimit -u`" 
echo ""
echo "CPU physical core:`cat /proc/cpuinfo |grep "physical id"|sort |uniq|wc -l`" 
echo ""
echo "System memory"
free -g
echo ""
Myid=`who am i| awk '{print$1}'`
id $Myid
echo ""
echo "ls -l /apps"
ls -l /apps
echo "Hard disk usage: `df -h | grep /apps`"
echo "##############################################################"