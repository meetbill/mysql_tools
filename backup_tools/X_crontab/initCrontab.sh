#!/bin/bash 
#########################################################################
# File Name: initCrontab.sh
# Author: meetbill
# mail: meetbill@163.com
# Created Time: 2017-10-19 23:10:35
#########################################################################
function InitCrontab(){
	echo "initCrontab"
	crontab -l -u root > mycron
    CHECK_MYSQL=$(grep -c "mysqlbackup" mycron)
    if [[ "w${CHECK_MYSQL}" == "w0" ]]
    then
	    echo "0 4 * * * bash /opt/X_crontab/mysqlbackup/backmysql.sh 2>&1" >> mycron
    fi
    crontab -u root mycron
    rm -rf  mycron
	return 0
}

CUR_DIR=$(cd `dirname $0`; pwd)
cd ${CUR_DIR}
InitCrontab
