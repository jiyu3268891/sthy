#!/bin/bash
if [ -z "$ENV_HOME" ];then
        PRG="$0"
        PRGDIR=`dirname "$PRG"`
        ENV_HOME=`cd "$PRGDIR"/.. ;pwd`
        . "$ENV_HOME"/bin/setEnv.sh
fi
#Cluster standard values md5.log
find "$ENV_HOME"/conf "$ENV_HOME"/lib -type f -print0 | xargs -0 md5sum | sort -u > $ENV_HOME/bin/md5.log
find "$ENV_HOME"/conf "$ENV_HOME"/lib -type f -print0 | xargs -0 ls > $ENV_HOME/bin/filelist.log
#Other Cluster members md5.log and filelist log
localhost=`hostname | grep -o '[0-9]\+'`
IPLIST=`cat "$PRJ_HOME"/conf/cluster-conf.properties |grep _member |grep -v "$localhost"|sed 's/^[ \t]*//g' |grep -v "^#" |cut -d= -f2 | sort -u`
for ip in $IPLIST
do
ssh $ip "find "$ENV_HOME"/conf "$ENV_HOME"/lib -type f -print0 | xargs -0 md5sum | sort -u " > ${ip}md5.log
done

for ip in $IPLIST
do
ssh $ip "find "$ENV_HOME"/conf "$ENV_HOME"/lib -type f -print0 | xargs -0 ls" > ${ip}filelist.log 

done

rm -rf $ENV_HOME/bin/compare.log
#find missingfiles and unnecessaryfiles

cd $ENV_HOME/bin
echo "========Missing Files========" >>$ENV_HOME/bin/compare.log 
for ip in $IPLIST
do
	missingfiles=`grep -vwf ${ip}filelist.log filelist.log | awk '{print $NF}' `

	if [ -n "$missingfiles" ]
	then
	echo "$ip missing files:" >> $ENV_HOME/bin/compare.log
	echo "$missingfiles">>$ENV_HOME/bin/compare.log
	echo "" >> $ENV_HOME/bin/compare.log

	fi
done
echo "========Unnecessary Files========">>$ENV_HOME/bin/compare.log 
for ip in $IPLIST
do
	unnecessaryfiles=`grep -vwf filelist.log ${ip}filelist.log | awk '{print $NF}'`
	if [ -n "$unnecessaryfiles" ]
	then
	echo "$ip unnecessaryfiles files:" >> $ENV_HOME/bin/compare.log
	echo "$unnecessaryfiles">>$ENV_HOME/bin/compare.log
	echo "" >> $ENV_HOME/bin/compare.log

	fi
done
rm -rf *filelist.log

#find changed files
echo "========Changed Files========">>$ENV_HOME/bin/compare.log 
for ip in $IPLIST
do
	comm -3 ${ip}md5.log md5.log | awk '{print $NF}' > comparemd5.log
	comparemd5=`awk '{a[$0]+=1;if(a[$0]>1) print $0}' comparemd5.log`
	if [ -n "$comparemd5" ]
	then
	echo "$ip changed files" >> compare.log
	awk '{a[$0]+=1;if(a[$0]>1) print $0}' comparemd5.log >>compare.log 	

	fi
done
rm -rf *md5.log
cat compare.log
#cat md5.log | sort -u | awk '{print $2}' > ./errorfile.log
#echo "The file as follow is not the same in the cluster:"
#awk '{a[$0]+=1;if(a[$0]>1) print $0}' errorfile.log	
##rm -rf md5.log
#rm -rf errorfile.log 
#
