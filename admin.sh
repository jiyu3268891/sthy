#!/bin/sh
#gemfire admin 
index=1
out='true'

#set classpath
PRG=$0
PRGDIR=`dirname "$PRG"`
ENV_HOME=`cd "$PRGDIR"/..;pwd`
. "$ENV_HOME"/bin/setEnv.sh

#loop for get control message
while test -n "$out"
do
if [ $index -gt 1 ]
then
   echo "press any key to continue:"
   read anykey
else
   index=$[$index+1]
fi
clear
echo "+======================================================================+"
echo "|       This shell will accept input command to do gemfire control     |"
echo "+======================================================================+"
echo "Plean enter the command:"
select out in "start_locator" "clean_log" "start_datastore" "gfsh" "stop_locator" "clean_datastore" "stop_datastore" "jps_all" "start_ws" "help" "quit";do
break
done
echo "you have selected $out"
if [ "$out" = 'quit' ]
then
    break
elif [ "$out" = 'help' ]
then 
   . "$PRJ_HOME"/bin/help.sh
else
   . "$PRJ_HOME"/bin/appbash.sh $out
fi
done
