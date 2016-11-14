#!/bin/bash

# xd or gf
MARK=
if [[ $3 =~ "spring-xd" ]]; then
	MARK="xd"
elif [ -z "$ENV_HOME" ];then
		if [ -z "$3" ] ;then
			PRG="$0"
			PRGDIR=`dirname "$PRG"`
			ENV_HOME=`cd "$PRGDIR"/.. ;pwd`
		else
			PRGDIR=$3
			ENV_HOME=`cd "$PRGDIR"/ ;pwd`
		fi
		echo $ENV_HOME
        . "$ENV_HOME"/bin/setEnv4ver.sh
fi
# Default Values
UNAME=`whoami`
CI_NAME=$1
ALIAS_NAME=$2
java_low_ver=1.8.0
gfsh_low_ver=8.2.0
adf_low_ver=0.2.0
zk_home=/apps/adf/zookeeper-3.4.6
zk_low_ver=3.4.0
hnofile=72000
snofile=72000
hnproc=72000
snproc=72000
passexp="never"
passina="never"
accountexp="never"
passmin=0
passmax=99999
springxd_low_ver=1.3.0
PASSTXT="\033[0m\033[32mPASS\033[0m"
FAILTXT="\033[0m\033[31mFAIL\033[0m"
#PASSTXT="PASS"
#FAILTXT="FAIL"

echo "******************************************"
echo "*** Start Verification "
echo "*** CI：$CI_NAME "
echo "*** Server Name: $ALIAS_NAME/`hostname` "
echo "*** Date: `date`"
echo "******************************************"
echo "### Test 1 - Step 1 ###"
java -version>tempjavaver 2>&1
java_cur_ver=`cat tempjavaver | grep version | cut -d\" -f2`
rm -rf tempjavaver
echo "java version: $java_cur_ver"
if [ "$java_low_ver" \> "$java_cur_ver" ] ;then
	echo -e "==>$FAILTXT (version $java_low_ver or reater) "
else
	echo -e "==>$PASSTXT (version $java_low_ver or greater) "
fi
echo ""

if [ "$MARK" = "gf" ]; then
	echo "### Test 1 - Step 2 ###"
	gfsh_cur_ver=`$GEMFIRE/bin/gfsh version`
	echo "gfsh version: $gfsh_cur_ver"
	if [ "$gfsh_low_ver" \> "$gfsh_cur_ver" ] ;then
		echo -e "==>$FAILTXT (version $gfsh_low_ver or greater) "
	else
		echo -e "==>$PASSTXT (version $gfsh_low_ver or greater) "
	fi
	echo ""
	echo "### Test 1 -  Step 3 ### "
	adf_core=`ls "$ENV_HOME"/lib | grep adf-core`
	adf_cur_ver=`echo $adf_core | cut -d- -f3`
	echo "ADF version: $adf_core"
	if [ "$adf_low_ver" \> "$adf_cur_ver" ] ;then
		echo -e "==>$FAILTXT (version $adf_low_ver or greater) "
	else
		echo -e "==>$PASSTXT (version $adf_low_ver or greater) "
	fi
elif [ "$MARK" = "xd" ]; then
	echo "### Test 1 - Step 2 ###"
	cd $3/shell/bin
	./xd-shell version > tempxdver 2>&1
	springxd_cur_ver=`cat tempxdver | grep INFO | cut -d: -f2 | sed 's/^[ \t]*//g'`
	rm -rf tempxdver
	echo "springxd version: $springxd_cur_ver"
	if [ "$springxd_low_ver" \> "$springxd_cur_ver" ] ;then
		echo -e "==>$FAILTXT (version $springxd_low_ver or greater) "
	else
		echo -e "==>$PASSTXT (version $springxd_low_ver or greater) "
	fi
        echo ""
	echo "### Test 1 -  Step 3 ### "
	zk_core=`ls $zk_home | grep zookeeper |grep -n 'jar$'`
	zk_cur_ver=`echo $zk_core | cut -d- -f2 | cut -d. -f1-3`
	echo "Zookeeper version: $zk_cur_ver"
	if [ "$zk_low_ver" \> "$zk_cur_ver" ] ;then
		echo -e "==>$FAILTXT (version $zk_low_ver or greater) "
	else
		echo -e "==>$PASSTXT (version $zk_low_ver or greater) "
	fi
fi
echo ""
echo "### Test 2 -  Step 1 ###" 
hnofile_cur=`ulimit -Hn`
echo "HARD ulimit open_files: $hnofile_cur"
if [[ $hnofile -eq $hnofile_cur ]] ; then
	echo -e "==>$PASSTXT hard ulimit open_files ($hnofile) "
else
	echo -e "==>$FAILTXT hard ulimit open_files ($hnofile) "
fi
echo ""
echo "### Test 2 -  Step 2 ###" 
snofile_cur=`ulimit -Sn`
echo "SOFT ulimit open_files: $snofile_cur"
if [[ $snofile -eq $snofile_cur ]] ; then
	echo -e "==>$PASSTXT soft ulimit open_files ($snofile) "
else
	echo -e "==>$FAILTXT soft ulimit open_files ($snofile) "
fi
echo ""
echo "### Test 2 -  Step 3 ###" 
hnproc_cur=`ulimit -Hu`
echo "HARD ulimit max_user_processes: $hnproc_cur"
if [[ $hnproc -eq $hnproc_cur ]] ; then
	echo -e "==>$PASSTXT hard ulimit max_user_processes($hnproc) "
else
	echo -e "==>$FAILTXT hard ulimit max_user_processes ($hnproc) "
fi
echo ""
echo "### Test 2 -  Step 4 ###" 
snproc_cur=`ulimit -Su`
echo "SOFT ulimit max_user_processes: $snproc_cur"
if [[ $snproc -eq $snproc_cur ]] ; then
	echo -e "==>$PASSTXT soft ulimit max_user_processes($snproc) "
else
	echo -e "==>$FAILTXT soft ulimit max_user_processes ($snproc) "
fi
echo ""
echo "### Test 2 -  Step 5 ###" 
passexp_cur=`chage -l $UNAME | grep "^Password expires" | cut -d":" -f2 | awk '{gsub(/^ +| +$/,"")} {print $0 }'`
echo "$UNAME PASSWORD_EXPIRES: $passexp_cur"
if [ "$passexp" = "$passexp_cur" ] ;then
	echo -e "==>$PASSTXT ASSWORD_EXPIRES ($passexp) "
else
	echo -e "==>$FAILTXT ASSWORD_EXPIRES ($passexp) "
fi
echo ""
echo "### Test 2 -  Step 6 ###" 
passina_cur=`chage -l $UNAME | grep "^Password inactive" | cut -d":" -f2 | awk '{gsub(/^ +| +$/,"")} {print $0 }'`
echo "$UNAME PASSWORD_INACTIVE: $passina_cur"
if [ "$passina" = "$passina_cur" ] ;then
	echo -e "==>$PASSTXT PASSWORD_INACTIVE ($passina) "
else
	echo -e "==>$FAILTXT PASSWORD_INACTIVE ($passina) "
fi
echo ""
echo "### Test 2 -  Step 7 ###" 
accountexp_cur=`chage -l $UNAME | grep "^Account expires" | cut -d":" -f2 | awk '{gsub(/^ +| +$/,"")} {print $0 }'`
echo "$UNAME ACCOUNT_EXPIRES: $accountexp_cur"
if [ "$accountexp" = "$accountexp_cur" ] ;then
	echo -e "==>$PASSTXT ACCOUNT_EXPIRES ($accountexp) "
else
	echo -e "==>$FAILTXT ACCOUNT_EXPIRES ($accountexp) "
fi
echo ""
echo "### Test 2 -  Step 8 ### "
passmin_cur=`chage -l $UNAME | grep "^Minimum number" | cut -d":" -f2 | awk '{gsub(/^ +| +$/,"")} {print $0 }'`
echo "$UNAME MIN_DAYS: $passmin_cur"
if [[ $passmin -eq $passmin_cur ]] ;then
	echo -e "==>$PASSTXT MIN_DAYS ($passmin) "
else
	echo -e "==>$FAILTXT MIN_DAYS ($passmin) "
fi
echo ""
echo "### Test 2 -  Step 9 ###" 
passmax_cur=`chage -l $UNAME | grep "^Maximum number" | cut -d":" -f2 | awk '{gsub(/^ +| +$/,"")} {print $0 }'`
echo "$UNAME MAX_DAYS: $passmax_cur"
if [[ $passmax -eq $passmax_cur ]] ;then
	echo -e "==>$PASSTXT MAX_DAYS ($passmax) "
else
	echo -e "==>$FAILTXT MAX_DAYS ($passmax) "
fi

echo "*******************************************"
echo "*** End Verification"
echo "*******************************************"
