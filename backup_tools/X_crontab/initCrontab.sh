#!/bin/bash 


function InitCrontab(){
	echo "initCrontab"


	date >> /opt/X_crontab/CrontabBackup/crontab.bak
	crontab -l >> /opt/X_crontab/CrontabBackup/crontab.bak
	echo "0 4 * * * sh /opt/X_crontab/mysqlbackup/backmysql.sh 2>&1" >> mycron
	crontab -r
	crontab mycron
	rm -rf  mycron
	return 0
}

InitCrontab
