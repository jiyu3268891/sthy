if [ -z "$ENV_HOME" ];then
        PRG="$0"
        PRGDIR=`dirname "$PRG"`
        ENV_HOME=`cd "$PRGDIR"/.. ;pwd`
        . "$ENV_HOME"/bin/setEnv.sh
fi

# cuurent path
CURRENT_PARH=${ENV_HOME}/bin
# Grid name
GRID_NAME=`cat "$ENV_HOME"/conf/env.properties | grep system.gridname | sed 's/^[ \t]*//g' | grep -v "^#" | cut -d= -f2`
# the path of the file backup 
BAK_HOME_PATH=`dirname "$PRJ_HOME"`
BAK_PATH=${BAK_HOME_PATH}/bakregions/${GRID_NAME}_bak
# 1 day ago
BAK_PRE_TIME=`date -d "1 day ago" +"%Y%m%d%H%M%S"`
BAK_TIME=`date "+%Y%m%d%H%M%S"`
# Specify export node
#EXPORT_NODE=`cat ${CURRENT_PARH}/eximport.properties | grep bakmembernode | sed 's/^[ \t]*//g' | grep -v "^#" |cut -d= -f2`
# obtain host name
declare -l HOSTNAME=`hostname`
EXPORT_NODE=${HOSTNAME}.jnj.com-s-s1
#HOSTNAME=`hostname`
#EXPORT_NODE=${HOSTNAME}-s-s1
# region name
#REGIONS_NAME=`cat ${CURRENT_PARH}/${GRID_NAME}_Regions | sed 's/^[ \t]*//g' |grep -v "^#" `
# temp regions file
REGIONS_FILE=${GRID_NAME}_Regions
# backup folder 
FOLDER_PATH=${BAK_PATH}/${GRID_NAME}
# locator
LOCATOR_INFO=`cat "$ENV_HOME"/conf/env.properties|grep gs.locators |sed 's/^[ \t]*//g' |grep -v "^#" |cut -d= -f2 | cut -d, -f1 | cut -d[ -f1`
# jmx port
JMX_PORT=`cat "$ENV_HOME"/conf/env.properties|grep jmx.manager.port |sed 's/^[ \t]*//g' |grep -v "^#" |cut -d= -f2`

# make temp regions file
$GEMFIRE/bin/gfsh -e "connect --jmx-manager=$LOCATOR_INFO[$JMX_PORT] --user=admin --password=QL0AFWMIX8NRZTKeof9cXsvbvu8= --use-ssl --security-properties-file=$ENV_HOME/conf/ssl/a1.properties" -e "list regions" > ./tempRegionsfile

startNum=`grep -n "List of regions" ./tempRegionsfile | cut -d: -f1`
# check file 
if [ -z $startNum ]
then
    echo "Error:please check if the gfsh connect is normal!"
	exit 1
fi
let "startNum = $startNum + 1"
totalNum=`cat ./tempRegionsfile | wc -l`
let "totalNum=$totalNum - $startNum"
tail -n $totalNum ./tempRegionsfile > $REGIONS_FILE
rm -r -f ./tempRegionsfile
REGIONS_NAME=`cat ${CURRENT_PARH}/${GRID_NAME}_Regions | sed 's/^[ \t]*//g' |grep -v "^#" `
rm -rf ./$REGIONS_FILE

# check path
if [ ! -d $FOLDER_PATH ]
then
    mkdir -p ${FOLDER_PATH}
	echo $BAK_TIME > ${FOLDER_PATH}/baktimeinfo
	# backup server.xml
	cp "$ENV_HOME"/conf/"$GRID_NAME"-server.xml  ${FOLDER_PATH}/"$GRID_NAME"-server.xml."$BAK_TIME"
else
    if [ -f ${FOLDER_PATH}/baktimeinfo ]
	then 
	    oldfilename=`cat  ${FOLDER_PATH}/baktimeinfo`
		if [ -z ${oldfilename} ] 
		then 
		    oldfilename=${BAK_PRE_TIME}
		fi
	else
	    oldfilename=${BAK_PRE_TIME}
	fi
	mv ${FOLDER_PATH} ${BAK_PATH}/${GRID_NAME}_${oldfilename}
	mkdir -p ${FOLDER_PATH}
	echo $BAK_TIME > ${FOLDER_PATH}/baktimeinfo
	# backup server.xml
	cp "$ENV_HOME"/conf/"$GRID_NAME"-server.xml  ${FOLDER_PATH}/"$GRID_NAME"-server.xml."$BAK_TIME"
fi

# delete old file and make temp gfshfile
rm -rf ${CURRENT_PARH}/exportdata.sh
echo "connect --jmx-manager=$LOCATOR_INFO[$JMX_PORT] --user=admin --password=QL0AFWMIX8NRZTKeof9cXsvbvu8= --use-ssl --security-properties-file=$ENV_HOME/conf/ssl/a1.properties" >> exportdata.sh
for i in $REGIONS_NAME
do 
    count=`echo $i | grep -o '/' | wc -l`
    if [ $count -eq 0 ] 
    then
        echo "export data --region=/$i --file=${FOLDER_PATH}/${i}_bk.gfd  --member=$EXPORT_NODE" >> exportdata.sh
    else
        tempname=`echo $i | cut -d/ -f-$count`
		let "count = $count + 1"
        regionname=`echo $i | cut -d/ -f$count`
        if [ ! -d ${FOLDER_PATH}/${tempname} ]
        then
            mkdir -p ${FOLDER_PATH}/${tempname}
        fi
        echo "export data --region=/$i --file=${FOLDER_PATH}/${i}_bk.gfd  --member=$EXPORT_NODE" >> exportdata.sh
    fi
done
echo "sh rm -rf ${CURRENT_PARH}/exportdata.sh" >> exportdata.sh
chmod +x ${CURRENT_PARH}/exportdata.sh

# excute backup
$GEMFIRE/bin/gfsh run --file=./exportdata.sh
echo "ok!"