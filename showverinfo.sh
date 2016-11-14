#!/bin/bash

if [ "$1" = "-help" ]; then
	echo "==Option:1)Param1 (configuration information),Param2 (gf | xd) "
    echo "  Usage: show cluster version information. Example:showverinfo.sh adfver-conf-QA_ihub.properties gf"
	echo "==Option:2)-help "
	echo "  Usage:List command descriptions. Example:showverinfo.sh -help"
	exit 0
fi

if [ $# != 2 ]; then
	echo "ERROR: no options. Please use '-help' to view options."
	exit 1
fi

# check 
CONF_FILE=$1
PRGCUR="$0"
PRGDIRCUR=`dirname "$PRGCUR"`

if [ "$2" = "gf" ]; then
	# host info 
	ADF_CLUSTER=`cat "$PRGDIRCUR"/"$CONF_FILE" | grep _member | sed 's/^[ \t]*//g' |grep -v "^#" |cut -d= -f2 | sort -u`
	# adf home path
	ADF_PATH=`cat "$PRGDIRCUR"/"$CONF_FILE" | grep adf_home | sed 's/^[ \t]*//g' |grep -v "^#" |cut -d= -f2`
	for tmp in $ADF_CLUSTER
		do
			ALIAS_NAME=`cat "$PRGDIRCUR"/"$CONF_FILE" | grep "$tmp" | sed 's/^[ \t]*//g' |grep -v "^#" | cut -d= -f3 | sort -u`
			CI_NAME=`cat "$PRGDIRCUR"/"$CONF_FILE" | grep "$tmp" | sed 's/^[ \t]*//g' |grep -v "^#" | cut -d= -f4 | sort -u`
			if [ "$tmp" = "`hostname`" ] || [ "$tmp" = "`hostname -i`" ] ;then
			. $ADF_PATH/bin/getverinfo.sh $CI_NAME $ALIAS_NAME $ADF_PATH
			else
			ssh $ALIAS_NAME "$ADF_PATH/bin/getverinfo.sh $CI_NAME $ALIAS_NAME"
			fi
		done
fi
if [ "$2" = "xd" ]; then
	# spring xd version information
	SPRINGXD=`cat "$PRGDIRCUR"/"$CONF_FILE" | grep springxd_host | sed 's/^[ \t]*//g' |grep -v "^#" |cut -d= -f2 | sort -u`
	SPRINGXD_PATH=`cat "$PRGDIRCUR"/"$CONF_FILE" | grep springxd_home | sed 's/^[ \t]*//g' |grep -v "^#" |cut -d= -f2`
	
	for tmp in $SPRINGXD
		do
			ALIAS_NAME=`cat "$PRGDIRCUR"/"$CONF_FILE" | grep "$tmp" | grep springxd_host | sed 's/^[ \t]*//g' |grep -v "^#" | cut -d= -f3 | sort -u`
			CI_NAME=`cat "$PRGDIRCUR"/"$CONF_FILE" | grep "$tmp" | grep springxd_host | sed 's/^[ \t]*//g' |grep -v "^#" | cut -d= -f4 | sort -u`
			if [ "$tmp" = "`hostname`" ] || [ "$tmp" = "`hostname -i`" ] ;then
			. $SPRINGXD_PATH/xd/bin/getverinfo.sh $CI_NAME $ALIAS_NAME $ADF_PATH $SPRINGXD_PATH
			else
			ssh $ALIAS_NAME "$SPRINGXD_PATH/xd/bin/getverinfo.sh $CI_NAME $ALIAS_NAME $SPRINGXD_PATH"
			fi
		done
fi
	
