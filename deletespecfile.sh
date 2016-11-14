#!/bin/bash
if [ ! -n "$1" ]; then
        echo "ERROR: no command specify. Example: delete.sh /apps/adf/ihub/old.jar"
        exit 1
fi
if [ -z "$ENV_HOME" ];then
	PRG="$0"
	PRGDIR=`dirname "$PRG"`
	ENV_HOME=`cd "$PRGDIR"/.. ;pwd`
	. "$ENV_HOME"/bin/setEnv.sh
fi
# host info 
IPLIST=`cat "$PRJ_HOME"/conf/cluster-conf.properties |grep _member |sed 's/^[ \t]*//g' |grep -v "^#" |cut -d= -f2 | sort -u`

# If you want to force you to delete the folder,Please set up the second parameter to 'rf'. Example:delete.sh /apps/adf/ihub/work/server rf
if [ -n $2 ] && [ "$2" = "rf" ];then
	echo "Delete folder there are risks, are you sure to delete ?y or n"
	read reallydo
	if [ "$reallydo" = 'y' ];then
		for ip in $IPLIST
		do
			echo ssh $ip " rm -rf $1"
			ssh $ip " rm -rf $1"
		done
	fi
else
	echo "you really want to delete ?y or n"
	read reallydo
	if [ "$reallydo" = 'y' ];then
		for ip in $IPLIST
		do
			echo ssh $ip " rm $1"
			ssh $ip " rm $1"
		done
	fi
fi
