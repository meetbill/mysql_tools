#!/bin/bash
#########################################################################
# File Name: w.sh
# Author: meetbill
# mail: meetbill@163.com
# Created Time: 2015-10-14 11:49:17
# this script is to backup mysql.
#########################################################################
today=`date +%Y%m%d-%H-%M-%S`
config_path="/opt/X_crontab/mysqlbackup/backupdb.config"
keepday=90
log_name="mysql_backup.log"
db_exclude_list='(test|mysql|information_schema|performance_schema)'
version="1.0.2"

#{{{init_value
function init_value()
{
    back_dir=`cat $config_path | grep "back_dir" | awk -F = '{print $2}' `
    db_dump=`cat $config_path | grep "db_dump" | awk -F = '{print $2}' `
    db_mysql=`cat $config_path | grep "db_mysql" | awk -F = '{print $2}' `
    mysql_account=`cat $config_path | grep "mysql_account" | awk -F = '{print $2}' `
    mysql_password=`cat $config_path | grep "mysql_password" | awk -F = '{print $2}' `
    db_addr=`cat $config_path | grep "db_addr" | awk -F = '{print $2}' `
    db_port=`cat $config_path | grep "db_port" | awk -F = '{print $2}' `
    db_list=`cat $config_path | grep "db_list" | awk -F = '{print $2}' `
    log_dir=`cat $config_path | grep "log_dir" | awk -F = '{print $2}' `
    bos=`cat $config_path | grep "bos" | awk -F = '{print $2}' `
}
#}}}
#{{{make_log
function make_log()
{
    
	if [ ! -d ${log_dir} ]
	then
		mkdir -p ${log_dir}
	fi
    cd $log_dir
    if [ ! -e $log_name ] ;then 
       touch $log_name
       chmod 755 $log_name
       echo "version:[${version}] time:[$today] action:[create log file success]" >> $log_name
    fi 
    if [ ! -w $log_name -o ! -x $log_name ] ;then
       chmod 755 $log_name
    fi
}
#}}}
#{{{output_log
function output_log()
{
  
  echo "$1" >> $log_dir/$log_name
}
#}}}
#{{{check_dir
function check_dir()
{
   target_dir=$1
   if [ -e $target_dir/$today ] ;then
       output_log "$today has backup,now it will be overwrite"
   fi
}
#}}}
#{{{mk_dir
function mk_dir(){
    target_dir=$1
    if [ ! -e $target_dir/$today ]
    then
        mkdir -p $target_dir/$today/
        output_log "version:[${version}] create dir $today success"
    fi
    if [ ! -r $target_dir/$today ]
    then
        chmod 755 $target_dir/$today/
    fi
}
#}}}
#{{{db_backup
function db_backup(){
    target_dir=$1
    database_list=`$db_mysql -h $db_addr  -u$mysql_account -p$mysql_password  -P $db_port  -e "show databases" |grep -v "Database" | grep -E -v "$db_exclude_list"`
    for i in $database_list
    do
        db_in=`echo $db_list | grep "$i"`
        if [ "$db_in" == "" ] ; then
             continue
        fi         
       # echo "db backup $i"
        errno=`$db_dump -h $db_addr -u$mysql_account -p$mysql_password -P $db_port  $i  | gzip > $target_dir/$today/${i}.gz`
	if [ "$errno" == "" ] ; then
            if [ w${bos} == w"ON" ]
            then
                cd /opt/X_crontab/mysqlbackup/bce/
                python bos.py --key /$today/${i}.gz --file $target_dir/$today/${i}.gz
            fi
            output_log "success backup $i"
        else
            output_log "fail backup $i"
        fi
    done
}
#}}}
#{{{rm_old_dir
function rm_old_dir()
{
    target_dir=$1
    cd $target_dir 
    for i in `ls $target_dir/ | grep -E "^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$"`
     do
        n=$(echo "$(date +%s) - $(date -d "$i" +%s)"| bc )
        time_second=$(($keepday*86400))
        if [ -d $i -a $n -ge $time_second ] ; then
              
            rm -rf $target_dir/$i
            output_log "$i timeout,it is deleted"
        fi
     done
}
#}}}
function make_multiple()
{
    init_value
    make_log

    for diri in $back_dir
    do
        check_dir $diri
        mk_dir $diri
        db_backup $diri
        rm_old_dir $diri
    done
}
make_multiple
