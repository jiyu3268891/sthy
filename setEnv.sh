#!/bin/bash
if [ -z "$ENV_HOME" ];then
	PRG="$0"
	PRGDIR=`dirname "$PRG"`
	ENV_HOME=`cd "$PRGDIR"/.. ;pwd`
fi
if [ ! -r "$ENV_HOME"/conf/env.properties ]; then
    echo "Cannot find $ENV_HOME/conf/env.properties"
    echo "This file is needed to run this program"
    exit 1
fi
PRJ_HOME=`cat "$ENV_HOME"/conf/env.properties|grep gs.home |sed 's/^[ \t]*//g' |grep -v "^#" |cut -d= -f2`
PRJ_WORK=`cat "$ENV_HOME"/conf/env.properties|grep gs.work |sed 's/^[ \t]*//g' |grep -v "^#" |cut -d= -f2`
GS_HOME="$PRJ_HOME"
GS_WORK="$PRJ_WORK"
JAVA_HOME=`cat "$ENV_HOME"/conf/env.properties|grep JAVA_HOME |sed 's/^[ \t]*//g' |grep -v "^#" |cut -d= -f2`
GEMFIRE=`cat "$ENV_HOME"/conf/env.properties|grep GEMFIRE |sed 's/^[ \t]*//g' |grep -v "^#" |cut -d= -f2`

PRJ_LM=`cat $PRJ_HOME/conf/cluster-conf.properties |grep locator_member |sed 's/^[ \t]*//g' |grep -v "^#" |cut -d= -f2`
PRJ_SLO=`cat $PRJ_HOME/conf/cluster-conf.properties |grep start_locator_opts |sed 's/^[ \t]*//g' |grep -v "^#" |cut -d= -f2`
PRJ_SLP="locator.sh $PRJ_SLO"
PRJ_CM=`cat $PRJ_HOME/conf/cluster-conf.properties |grep cluster_member |sed 's/^[ \t]*//g' |grep -v "^#" |cut -d= -f2`
PRJ_SDO=`cat $PRJ_HOME/conf/cluster-conf.properties |grep start_datastore_opts |sed 's/^[ \t]*//g' |grep -v "^#" |cut -d= -f2`
PRJ_SDP="run.sh $PRJ_SDO"

# Add on extra jar files to CLASSPATH
if [ ! -z "$CLASSPATH" ] ; then
	CLASSPATH="$CLASSPATH"
fi

GRID_CLASSPATH=$GS_HOME/conf:$GS_HOME/lib:$GS_HOME/lib/*:$GS_HOME/lib/common/*
if [ "$1" = "flag" ]; then
	GRID_CLASSPATH=
fi
CLASSPATH="$GRID_CLASSPATH":$GEMFIRE/lib/*:"$CLASSPATH"

PATH=$JAVA_HOME/bin:$PATH
echo $GRID_CLASSPATH
