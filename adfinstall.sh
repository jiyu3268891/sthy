#!/bin/sh
#Autoinstall
echo "===============Welcome to adf install environment==============="
echo "|                                                              |"                                                              
echo "|                                                              |"
echo "|                                                              |"
echo "|                                                              |"
echo "================================================================"
echo -e "\n"
#session log
#script -a /depot/fit_install/adf/log/`hostname`_`date  +%Y%m%d%H%M`.log
#directory path
cur_dir=$(pwd)
install_dir=/apps/adf/install
script_dir=/depot/fit_install/adf/version/bin
base_dir=/depot/fit_install/adf/version
choiseid=""


Init_mutualtrust()
{
	if [ "$listpath" = "" ]
	then
	listpath=$install_dir
	fi
	if [ ! -f $listpath/ip.list ]
	then
	echo "The ip.list is not found in specified path" && exit 1
	fi
	cd $listpath
	cp $script_dir/mutualtrust.sh .
	./mutualtrust.sh
	
}

Init_environment()
{
	if [ "$listpath" = "" ]
	then
	listpath=$install_dir
	fi
	#jdk and Pivotal_GemFire_820_b17919_Linux
	if [ ! -f $listpath/ip.list ]
	then
	echo "The ip.list is not found in specified path" && exit 1
	fi
	if [ ! -d /apps/adf/jdk1.8.0_60 ] || [ ! -d /apps/adf/Pivotal_GemFire_820_b17919_Linux ]
	then
		cp /depot/fit_install/jdk/jdk1.8.0_60.tar.gz /apps/adf
		cp /depot/fit_install/Pivotal/Pivotal_GemFire_820_b17919_Linux.tar.gz /apps/adf
		cd /apps/adf/
		tar -xvf jdk1.8.0_60.tar.gz
		tar -xvf Pivotal_GemFire_820_b17919_Linux.tar.gz
		envlist=`cat ${listpath}/ip.list`
		for tmp in $envlist
		do
		scp -r /apps/adf/jdk1.8.0_60 $tmp:/apps/adf
		scp -r /apps/adf/Pivotal_GemFire_820_b17919_Linux $tmp:/apps/adf
		done
	fi
}
Init_choise()
{	
	choise=$1
	while [[ "x"$choise != "xy" && "x"$choise != "xn" && "$choise" != "" ]] 
	do 
	read -p "please input y or n,or input enter:" choise
	done
	choiseid=$choise
}	
Init_control()
{
if [ -d /apps/adf/control ]
then
	echo "control is already exsit,please check"
else
	cp -r /depot/fit_install/adf/version/control /apps/adf
	cp -r ${base_dir}/$versionid/lib /apps/adf/control
	cp -r ${base_dir}/bin /apps/adf/$gridid
	locator01=`cat $listpath/ip.list | awk 'NR==1{print}'`
	locator02=`cat $listpath/ip.list | awk 'NR==2{print}'`
	#cluster-conf.properties
		echo "Please must set the locator in the header of the ip.list!!!"
		read -p "You have already set the first two member as locator(Default locator is $locator01, $locator02),y or n?"  locatorid
		Init_choise $locatorid
		locatorid=$choiseid
		if [ "x"$choiseid = "xn" ]
		then
		echo "Please put the locator in the header of ip.list,and then start again." && exit 1
		fi
		read -p "$locator01,$locator02 are also as datastorenodes(Default n),y or n?  "  datanodeid
		Init_choise $datanodeid
		datanodeid=$choiseid
		echo ""$datanodeid" is ok"
		rm -rf /apps/adf/$gridid/conf/cluster-conf.properties
		cp $listpath/ip.list /apps/adf/$gridid/conf/cluster-conf.properties
		sed -i "s/"$locator01"/locator_member="$locator01"/g" /apps/adf/$gridid/conf/cluster-conf.properties
		sed -i "s/"$locator02"/locator_member="$locator02"/g" /apps/adf/$gridid/conf/cluster-conf.properties
		clusterconf=`cat /apps/adf/$gridid/conf/cluster-conf.properties | grep -v locator`
		for datanode in $clusterconf
		do
			sed -i "s/"$datanode"/cluster_member="$datanode"/g" /apps/adf/$gridid/conf/cluster-conf.properties
		done
		if [ "x"$datanodeid = "xy" ]
		then
			echo "cluster_member=$locator01" >> /apps/adf/$gridid/conf/cluster-conf.properties
			echo "cluster_member=$locator02" >> /apps/adf/$gridid/conf/cluster-conf.properties
		fi
		echo "start_datastore_opts=1 1048m 256m 70 control-server.xml" >> /apps/adf/$gridid/conf/cluster-conf.properties
		echo "start_locator_opts=1 2048m 14000" >> /apps/adf/$gridid/conf/cluster-conf.properties			
		sed  -i '/^$/d' /apps/adf/$gridid/conf/cluster-conf.properties
		#env.properties
		locatorsline=`grep -n gs.locators /apps/adf/$gridid/conf/env.properties | cut -d: -f1`
		sed -i ''$locatorsline's/^.*$/gs.locators='$locator01'[14000],'$locator02'[14000]/' /apps/adf/$gridid/conf/env.properties
		namingserverline=`grep -n naming.server /apps/adf/$gridid/conf/env.properties | cut -d: -f1`
		sed -i ''$namingserverline's/^.*$/naming.server='$locator01'[14000],'$locator02'[14000]/' /apps/adf/$gridid/conf/env.properties
		cd /apps/adf/$gridid/bin
		./scp.sh /apps/adf/$gridid /apps/adf
fi
}
Init_grid()
{
	if [ "$listpath" = "" ]
	then
	listpath=$install_dir
	fi
	if [ ! -f $listpath/ip.list ]
	then
	echo "The ip.list is not found in specified path" && exit 1
	fi
	if [ "$gridid" = "" ]
	then
	gridid="grid"
	fi
	if [ "$versionid" = "" ]
	then
	versionid="0.2.21"
	fi
	if [ -d /apps/adf/$gridid ] || [ -d /apps/adf/grid ]
	then
		echo "grid is already exsit,please check" && exit 1
	else
		if [ "$gridid" = "control" ]
		then
			Init_control&&exit 1
		else
			cp -r /depot/fit_install/adf/version/grid /apps/adf
			if [ "$gridid" != "grid" ]
			then
			mv /apps/adf/grid /apps/adf/$gridid
			fi
		fi
	fi
	#env parameter
	locator01=`cat $listpath/ip.list | awk 'NR==1{print}'`
	locator02=`cat $listpath/ip.list | awk 'NR==2{print}'`
	datanode01=`cat $listpath/ip.list | awk 'NR==3{print}'`
	cd ${base_dir}
	if [ -d $versionid ]
	then
	#grid templet
		cp -r ${base_dir}/$versionid/conf /apps/adf/$gridid
		cp -r ${base_dir}/$versionid/lib /apps/adf/$gridid
		cp -r ${base_dir}/bin /apps/adf/$gridid
	#cluster-conf.properties
		echo "Please must set the locator in the header of the ip.list!!!"
		read -p "You have already set the first two member as locator(Default locator is $locator01, $locator02),y or n?"  locatorid
		Init_choise $locatorid
		locatorid=$choiseid
		if [ "x"$choiseid = "xn" ]
		then
		echo "Please put the locator in the header of ip.list,and then start again." && exit 1
		fi
		read -p "$locator01,$locator02 are also as datastorenodes(Default n),y or n?  "  datanodeid
		Init_choise $datanodeid
		datanodeid=$choiseid
		rm -rf /apps/adf/$gridid/conf/cluster-conf.properties
		cp $listpath/ip.list /apps/adf/$gridid/conf/cluster-conf.properties
		sed -i "s/"$locator01"/locator_member="$locator01"/g" /apps/adf/$gridid/conf/cluster-conf.properties
		sed -i "s/"$locator02"/locator_member="$locator02"/g" /apps/adf/$gridid/conf/cluster-conf.properties
		clusterconf=`cat /apps/adf/$gridid/conf/cluster-conf.properties | grep -v locator`
		for datanode in $clusterconf
		do
			sed -i "s/"$datanode"/cluster_member="$datanode"/g" /apps/adf/$gridid/conf/cluster-conf.properties
		done
		if [ "x"$datanodeid = "xy" ]
		then
			echo "cluster_member=$locator01" >> /apps/adf/$gridid/conf/cluster-conf.properties
			echo "cluster_member=$locator02" >> /apps/adf/$gridid/conf/cluster-conf.properties
		fi
		mem=`ssh $datanode01 "free -g" | grep Mem | awk ' { print $2}'`
		mem=$(( $mem -20 ))
		read -p "Please input the start_datastore_opts,for example(Default:1 "$mem"g `expr $mem / 4`g 70 $gridid-server.xml):" datastore_opts
		echo ""
		read -p "Please input the start_locator_opts,for example(Default:1 2048m 14001):" locator_opts
		echo ""
		
		if [ "$datastore_opts" = "" ]
		then
			datastore_opts="1 "$mem"g `expr $mem / 4`g 70 $gridid-server.xml"
		fi
		if [ "$locator_opts" = "" ]
		then
			locator_opts="1 2048m 14001"
		fi

		echo "start_datastore_opts="$datastore_opts"" >> /apps/adf/$gridid/conf/cluster-conf.properties
		echo "start_locator_opts="$locator_opts"" >> /apps/adf/$gridid/conf/cluster-conf.properties			
		sed  -i '/^$/d' /apps/adf/$gridid/conf/cluster-conf.properties
	#env.properties
		locatorsline=`grep -n gs.locators /apps/adf/$gridid/conf/env.properties | cut -d: -f1`
		locatorsport=`cat /apps/adf/$gridid/conf/cluster-conf.properties | grep locator_opts | cut -d= -f2 | awk '{ print $3}'`
		read -p "Please input the master locator,naming.server= (Example:ITSUSABLSP00***,ITSUSABLSP00***)" namingserver
		sed -i ''$locatorsline's/^.*$/gs.locators='$locator01'['$locatorsport'],'$locator02'['$locatorsport']/' /apps/adf/$gridid/conf/env.properties
		namingserverline=`grep -n naming.server /apps/adf/$gridid/conf/env.properties | cut -d: -f1`
		masterlocator01=`echo $namingserver | cut -d, -f1`
		masterlocator02=`echo $namingserver | cut -d, -f2`
		sed -i ''$namingserverline's/^.*$/naming.server='$masterlocator01'[14000],'$masterlocator02'[14000]/' /apps/adf/$gridid/conf/env.properties
		read -p "master or control?(Example:control)" controlid
		echo ""
		read -p "Please input jmxport,For example(Default:1081)" jmxport
		echo ""
		if [ "x"$controlid = "xcontrol" ]
		then
			sed -i "/federal/s/master/control/g"  /apps/adf/$gridid/conf/env.properties
		fi
		if [ "$jmxport" != "1081" ] && [ "$jmxport" != "" ]
		then
		sed -i 's/1081/'$jmxport'/g' /apps/adf/$gridid/conf/env.properties
		fi
	#gfsecurity.properties && a1.properties
		if [ $gridid != "grid" ]
		then
			sed -i 's/grid/'$gridid'/g' /apps/adf/$gridid/conf/gfsecurity.properties
			sed -i 's/grid/'$gridid'/g' /apps/adf/$gridid/conf/ssl/a1.properties
			sed -i 's/grid/'$gridid'/g' /apps/adf/$gridid/conf/env.properties
		fi
	#log4j2-server.xml
		read -p "Please input the log path,For example(Default:/apps/adf/$gridid/log)" logpath
		if [ "$logpath" = "" ]
		then
		logpath=/apps/adf/$gridid/log
		fi
		
		echo $logpath > ./temlogpath
		sed -i "s/\//\\\\\//g" temlogpath
		logpath=`cat ./temlogpath`
		rm -rf ./temlogpath
		sed -i "s/\/fitshare\/INT2\/regionbak_log\/logs\/ihub/$logpath/g" /apps/adf/$gridid/conf/log4j2-server.xml
	#grid-server.xml
		mv grid-server.xml $gridid-server.xml
		cd /apps/adf/$gridid/bin
		./scp.sh /apps/adf/$gridid /apps/adf
	else
	#0.2.21
	echo "Version $ver is not exit,Please input again" && exit 1	
	fi
		
}

#main function
mkdir -p $install_dir
#parameter
#read -p "Do you want to create mutualtrust?(Default y),y or n?" mutualtrustid
echo "ip.list is such as
ITSUSABLSP00****
ITSUSABLSP00****
ITSUSABLSP00****
ITSUSABLSP00****
ITSUSABLSP00****"
read -p "Please input the path of the ip.list,(Default list /apps/adf/install):" listpath
echo ""
read -p "Do you want to creat mutual trust,y or n(Default y)" mutualtrustid
Init_choise $mutualtrustid
mutualtrustid=$choiseid
echo ""
read -p "Please input the grid name which you want to creat(Default grid):" gridid
echo ""
read -p "Please input the grid version which you want(Default 0.2.21):" versionid
if [ "$mutualtrustid" = "" ] ||  [ "$mutualtrustid" = "y" ]
then
Init_mutualtrust
fi
Init_environment
Init_grid