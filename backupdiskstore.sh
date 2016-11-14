#!/bin/bash
if [ -z "$ENV_HOME" ];then
        PRG="$0"
        PRGDIR=`dirname "$PRG"`
        ENV_HOME=`cd "$PRGDIR"/.. ;pwd`
        . "$ENV_HOME"/bin/setEnv.sh
fi

# username
USERNAME=$1
# password
USERPWD=$2
# locator
LOCATOR_INFO=`cat "$ENV_HOME"/conf/env.properties|grep gs.locators |sed 's/^[ \t]*//g' |grep -v "^#" |cut -d= -f2 | cut -d, -f1 | cut -d[ -f1`
# jmx port
JMX_PORT=`cat "$ENV_HOME"/conf/env.properties|grep jmx.manager.port |sed 's/^[ \t]*//g' |grep -v "^#" |cut -d= -f2`
# Grid name
GRID_NAME=`cat "$ENV_HOME"/conf/env.properties | grep system.gridname | sed 's/^[ \t]*//g' | grep -v "^#" | cut -d= -f2`
# datastore 
ADF_CLUSTER=`cat "$ENV_HOME"/conf/cluster-conf.properties |grep _member |sed 's/^[ \t]*//g' |grep -v "^#" |cut -d= -f2 | sort -u`
#backup path
bakuppath=/apps/adf/bakregions/${GRID_NAME}bak_diskstore
CURRENT_PARH=${ENV_HOME}/bin
if [ ! -d /apps/adf/bakregions/${GRID_NAME}bak_diskstore ];
then
mkdir -p /apps/adf/bakregions/${GRID_NAME}bak_diskstore
fi
# Determine whether to use the default user connections
if [ -z $USERNAME ] || [ -z $USERPWD ];
then
    USERNAME="admin"
	USERPWD="QL0AFWMIX8NRZTKeof9cXsvbvu8="
fi
#backupdiskstore
rm -rf ${CURRENT_PARH}/diskstore.sh
echo "connect --jmx-manager=$LOCATOR_INFO[$JMX_PORT] --user=admin --password=QL0AFWMIX8NRZTKeof9cXsvbvu8= --use-ssl --security-properties-file=$ENV_HOME/conf/ssl/a1.properties" >> ${CURRENT_PARH}/diskstore.sh
echo "backup disk-store --dir=${bakuppath}" >> ${CURRENT_PARH}/diskstore.sh
echo "history --clear" >> ${CURRENT_PARH}/diskstore.sh
chmod a+x ${CURRENT_PARH}/diskstore.sh
cd ${CURRENT_PARH}
$GEMFIRE/bin/gfsh run --file=${CURRENT_PARH}/diskstore.sh > ${bakuppath}/backupdiskstore.log

#Delete files 7 days ago 
time1=`date  +%Y%m%d%H%M`
time2=`date  +%Y%m%d --date '7 days ago'`
#time3=`date  +%Y-%m-%d-%H-%M`
time3=`date  +%Y-%m-%d`
time_del=`date  +%Y-%m-%d --date '7 days ago'`
cd ${bakuppath}
mv backupdiskstore.log backupdiskstore_$time1.log
rm -rf backupdiskstore_$time2*.log
for tmp in $ADF_CLUSTER
do
    declare -l HOSTNAME=$tmp
    ssh $tmp "rm -rf ${bakuppath}/${time_del}*"	
done

