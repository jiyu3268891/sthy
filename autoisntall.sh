#!/bin/sh
#Autoinstall
index=1
out='true'
#autoinstall path
preparepath=/depot/fit_install/adf/SHELL
localinstallpath=/apps/adf/install
autoinstallpath=/depot/fit_install/autoinstall
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
echo "|       This shell will accept input command to do autoinstall control     |"
echo "+======================================================================+"
echo "Plean enter the command:"
select out in "create_mutualtrust" "envcheck" "envprepare" "install_master_profile" "install_grid_profile" "quit";do
break
done
echo "you have selected $out"
if [ "$out" = 'quit' ]
then
    break
elif [ "$out" = 'create_mutualtrust' ]
then
	if [ ! -f ${localinstallpath}/ip.list ]
	then 
	scp fitadmin@ITSUSABLSP00450:${autoinstallpath}/ip.list ${localinstallpath}
	scp fitadmin@ITSUSABLSP00450:${preparepath}/mutualtrust.sh ${localinstallpath}
	echo "Please Edit /apps/adf/install/ip.list and then input command again!!!!!!" && exit 1
	fi
	./mutualtrust.sh
elif [ "$out" = 'envcheck' ]
then
	scp fitadmin@ITSUSABLSP00450:${preparepath}/envcheck.sh ${localinstallpath}
	scp fitadmin@ITSUSABLSP00450:${preparepath}/nodecheck.sh ${localinstallpath}
	./envcheck.sh
elif [ "$out" = 'envprepare' ]
then
	scp fitadmin@ITSUSABLSP00450:${autoinstallpath}/.bashrc ~/.bashrc
	scp fitadmin@ITSUSABLSP00450:${autoinstallpath}/jdk1.8.0_60.tar.gz /apps/adf
	scp fitadmin@ITSUSABLSP00450:${autoinstallpath}/Pivotal_GemFire_820_b17919_Linux.tar.gz /apps/adf
	cd /apps/adf
	tar -xvf jdk1.8.0_60.tar.gz
	tar -xvf Pivotal_GemFire_820_b17919_Linux.tar.gz
	scp fitadmin@ITSUSABLSP00450:${preparepath}/envprepare.sh ${localinstallpath}
	cd ${localinstallpath}
	./envprepare.sh
elif [ "$out" = 'install_grid_profile' ]
then
	if [ ! -f ${localinstallpath}/grid/id ]
	then
	mkdir -p ${localinstallpath}/grid
	scp fitadmin@ITSUSABLSP00450:${autoinstallpath}/grid/role-mapping.xml ${localinstallpath}/grid
	scp fitadmin@ITSUSABLSP00450:${autoinstallpath}/grid/cluster-conf.properties ${localinstallpath}/grid
	scp fitadmin@ITSUSABLSP00450:${autoinstallpath}/grid/gfsecurity.properties ${localinstallpath}/grid
	scp fitadmin@ITSUSABLSP00450:${autoinstallpath}/grid/env.properties ${localinstallpath}/grid
	scp fitadmin@ITSUSABLSP00450:${autoinstallpath}/grid/id ${localinstallpath}/grid
	echo "Please modify the configure files in /apps/adf/install/grid,and then input command again!!!!" && exit 1
	else
#security_account
	security_username=`cat ${localinstallpath}/grid/gfsecurity.properties | grep account-username | cut -d= -f2`
	security_password=`cat ${localinstallpath}/grid/gfsecurity.properties | grep account-password | cut -d= -f2`
#gridname		
	gridname=`cat ${localinstallpath}/grid/env.properties | grep gridname | cut -d= -f2`
#gridpath
	gridpath=/apps/adf/$gridname
#locator
	LOCATOR01=`cat ${localinstallpath}/grid/cluster-conf.properties | grep locator_member | cut -d= -f2 |awk 'NR==1{print}'`
	LOCATOR02=`cat ${localinstallpath}/grid/cluster-conf.properties | grep locator_member | cut -d= -f2 |awk 'NR==2{print}'`
#master locator
	masterlocator01=`cat ${localinstallpath}/grid/env.properties | grep masterlocator01 | cut -d= -f2`
	masterlocator02=`cat ${localinstallpath}/grid/env.properties | grep masterlocator02 | cut -d= -f2`
	mastergrid=`cat ${localinstallpath}/grid/env.properties | grep mastergrid | cut -d= -f2`
#memberheapsize
	memberheapsize=`cat ${localinstallpath}/grid/cluster-conf.properties | grep memberheapsize | cut -d= -f2`
#jmxport
	jmxport=`cat ${localinstallpath}/grid/env.properties | grep jmxport | cut -d= -f2`
	port=`cat ${localinstallpath}/grid/cluster-conf.properties | grep start_locator |cut -d= -f2 | awk '{print $NF}'`
	
	scp fitadmin@ITSUSABLSP00450:${autoinstallpath}/grid.tar.gz /apps/adf
	cd /apps/adf
	tar -xvf grid.tar.gz
	if [ ! -d ${gridpath} ]
	then
	mv /apps/adf/grid ${gridpath}
	else
	echo "error,the gird $gridname is exsit,Please check again" && exit 1
	fi
#cluster-conf.properties
	cp ${localinstallpath}/grid/cluster-conf.properties ${gridpath}/conf
#role-mapping.xml
	#GD_MANAGER member number
	cat ${localinstallpath}/role-mapping.xml >${gridpath}/conf/role-mapping.xml

#env.properties
	
	sed -i s/"\[gridname\]"/$gridname/g ${gridpath}/conf/env.properties
	sed -i s/"\[port\]"/$port/g ${gridpath}/conf/env.properties
	sed -i s/"\[jmxport\]"/$jmxport/g ${gridpath}/conf/env.properties
	sed -i s/"\[gridlocator01\]"/$LOCATOR01/g ${gridpath}/conf/env.properties
	sed -i s/"\[gridlocator02\]"/$LOCATOR02/g ${gridpath}/conf/env.properties
	sed -i s/"\[masterlocator01\]"/$masterlocator01/g ${gridpath}/conf/env.properties
	sed -i s/"\[masterlocator02\]"/$masterlocator02/g ${gridpath}/conf/env.properties
	sed -i s/"\[mastergrid\]"/$mastergrid/g ${gridpath}/conf/env.properties
#gfsecurity.properties
	sed -i s/"\[security_username\]"/$security_username/g ${gridpath}/conf/gfsecurity.properties
	sed -i s/"\[security_password\]"/$security_password/g ${gridpath}/conf/gfsecurity.properties
	sed -i s/"\[gridname\]"/$gridname/g ${gridpath}/conf/gfsecurity.properties
#a1.properties
	sed -i s/"\[gridname\]"/$gridname/g ${gridpath}/conf/ssl/a1.properties
#jarpath
	jarpath=`cat ${localinstallpath}/grid/env.properties | grep jarpath | cut -d= -f2`
	scp fitadmin@ITSUSABLSP00450:$jarpath ${gridpath}/
	scp fitadmin@ITSUSABLSP00450:$preparepath /apps/adf/$gridname/bin
	cd ${gridpath}/bin
	./scp.sh ${gridpath} /apps/adf
	fi
#grid-server.xml
	cd ${gridpath}/conf
	mv example-server.xml $gridname-server.xml
#distribute to all members
elif [ "$out" = 'install_master_profile' ]
then
	if [ ! -f ${localinstallpath}/control/controlid ]
	then
	mkdir -p ${localinstallpath}/control
	scp fitadmin@ITSUSABLSP00450:${autoinstallpath}/control/controlid ${localinstallpath}/control
	scp fitadmin@ITSUSABLSP00450:${autoinstallpath}/control/cluster-conf.properties ${localinstallpath}/control
	scp fitadmin@ITSUSABLSP00450:${autoinstallpath}/control/jarpath ${localinstallpath}/control
	echo "Please modify the configure files in /apps/adf/install/control,and then input command again!!!!" && exit 1
	else
	scp fitadmin@ITSUSABLSP00450:${autoinstallpath}/control.tar.gz /apps/adf
	if [ ! -d /apps/adf/control ]
	then
	cd /apps/adf
	tar -xvf control.tar.gz
	else
	echo "Control is exsit,please check" && exit 1
	fi
	#locator
	LOCATOR01=`cat ${localinstallpath}/control/cluster-conf.properties | grep locator_member | cut -d= -f2 |awk 'NR==1{print}'`
	LOCATOR02=`cat ${localinstallpath}/control/cluster-conf.properties | grep locator_member | cut -d= -f2 |awk 'NR==2{print}'`
	#cluster-conf.properties
	cp ${localinstallpath}/control/cluster-conf.properties /apps/adf/control/conf
	#env.properties
	sed -i s/"\[masterlocator01\]"/$LOCATOR01/g /apps/adf/control/conf/env.properties
	sed -i s/"\[masterlocator02\]"/$LOCATOR02/g /apps/adf/control/conf/env.properties
	jarpath=`cat ${localinstallpath}/control/jarpath | cut -d= -f2`
	scp fitadmin@ITSUSABLSP00450:$jarpath /apps/adf/control/lib
	scp fitadmin@ITSUSABLSP00450:$preparepath /apps/adf/control/bin
	cd /apps/adf/control/bin
	./scp.sh /apps/adf/control /apps/adf
	fi
	
else
	echo "error"
fi
done