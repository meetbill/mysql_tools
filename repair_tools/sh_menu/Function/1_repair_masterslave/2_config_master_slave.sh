#!/bin/bash
 
. /etc/rc.d/init.d/functions
 
if [ $# -ne 0 ];then
   echo "Usage:sh `basename $0`"
   exit 1
fi
 
#MASTER VARIABLES
##################################################################################
MYSQL_DIR=/usr/bin/
MASTER_USER=mysuser
MASTER_PASS=mypassword
MASTER_PORT=3306
MASTER_IP="172.16.104.60"
REP_USER=mysync
REP_PWD=mysyncpassword
DATABASE=xserver
##################################################################################
#SLAVE VARIABLES
##################################################################################
SLAVE_USER=myuser
SLAVE_PASS=mypassword
SLAVE_PORT=3307
SLAVE_IP="172.16.104.60"
##################################################################################

MASTER_DATA_PATH=/data/backup
TODAY=`date +%Y%m%d-%H-%M-%S`
MASTER_STATUS_FILE=${MASTER_DATA_PATH}/mysqllogs_${TODAY}.log
MASTER_DATA_FILE=${MASTER_DATA_PATH}/mysql_backup_${TODAY}.sql.gz
  
MASTER_MYSQL_CMD="$MYSQL_DIR/mysql -u$MASTER_USER -p$MASTER_PASS -h$MASTER_IP -P$MASTER_PORT"
MASTER_MYSQL_DUMP="$MYSQL_DIR/mysqldump -u$MASTER_USER -p$MASTER_PASS -h$MASTER_IP -P$MASTER_PORT   -B -F --single-transaction --events ${DATABASE} "

SLAVE_MYSQL_CMD="$MYSQL_DIR/mysql -u$SLAVE_USER -p$SLAVE_PASS -h$SLAVE_IP -P$SLAVE_PORT"
 
# 创建复制用户
[ ! -d $MASTER_DATA_PATH ] && mkdir -p $MASTER_DATA_PATH
[ `$MASTER_MYSQL_CMD -e "select user,host from mysql.user" |grep rep|wc -l` -ne 1 ] &&\
$MASTER_MYSQL_CMD -e "grant replication slave on *.* to '${REP_USER}' @'%' identified by '${REP_PWD}';" 
[ $? -eq 0  ] && action "[master] mysql create replication user" /bin/true  ||  action "[master] mysql create replication user" /bin/false || exit 1 
  
# 锁主机的表
$MASTER_MYSQL_CMD -e "flush tables with read lock;"
[ $? -eq 0  ] && action "[master] lock tables" /bin/true ||  action "[master] lock tables" /bin/false || exit 1 

# 查看主机状态
echo "-----show master status result-----" >$MASTER_STATUS_FILE
$MASTER_MYSQL_CMD -e "show master status;" >>$MASTER_STATUS_FILE
[ $? -eq 0  ] && action "[master] show master status" /bin/true ||  action "[master] show master status" /bin/false ||  exit 1
#echo "${MASTER_MYSQL_DUMP} | gzip > $MASTER_DATA_FILE"

# 备份主库
${MASTER_MYSQL_DUMP} | gzip > $MASTER_DATA_FILE 
[ $? -eq 0  ] && action "[master] backup master data" /bin/true || action "[master] backup master data" /bin/false || exit 1

# 将主库表锁释放
$MASTER_MYSQL_CMD -e "unlock tables;" 
[ $? -eq 0  ] && action "[master] unlock tables" /bin/true || action "[master] unlock tables" /bin/false || exit 1
#cat $MASTER_STATUS_FILE
 
###############################################################################
 
  
#recover
# 解压备份文件
[ -d ${MASTER_DATA_PATH} ]  && cd ${MASTER_DATA_PATH} && rm -f mysql_backup_${TODAY}.sql
gzip -d mysql_backup_${TODAY}.sql.gz
[ $? -eq 0  ] && action "[slave] unzip mysql data" /bin/true || action "[slave] unzip mysql data" /bin/false || exit 1

# 导入到从机器数据
$SLAVE_MYSQL_CMD < mysql_backup_${TODAY}.sql
[ $? -eq 0  ] && action "[slave] slave import data" /bin/true || action "[slave] slave import data" /bin/false || exit 1
MASTER_LOG_FILE=`tail -1 $MASTER_STATUS_FILE|cut -f1`
MASTER_LOG_POS=`tail -1 $MASTER_STATUS_FILE|cut -f2`
 
  
#config slave
 
$SLAVE_MYSQL_CMD -e "\
CHANGE MASTER TO  \
MASTER_HOST='$MASTER_IP', \
MASTER_PORT=$MASTER_PORT, \
MASTER_USER='$REP_USER', \
MASTER_PASSWORD='$REP_PWD', \
MASTER_LOG_FILE='$MASTER_LOG_FILE',\
MASTER_LOG_POS=$MASTER_LOG_POS;" 
 
 
# change master
if [ $? -eq 0  ] ;then 
     action "[slave] change MASTER to" /bin/true 
else
      action "[slave] change MASTER to" /bin/false 
      $SLAVE_MYSQL_CMD -e "show slave status\G"  >> $MASTER_STATUS_FILE
      exit 1
fi
 
 
$SLAVE_MYSQL_CMD -e "start slave;"
 
# 启动从库复制
[ $? -eq 0  ] && action "[slave] start slave" /bin/true || action "[slave] start slave" /bin/false || exit 1
$SLAVE_MYSQL_CMD -e "show slave status\G" |egrep "IO_Running|SQL_Running"  >>$MASTER_STATUS_FILE
 
MasterLogFile=`$SLAVE_MYSQL_CMD -e "show slave status\G" |egrep -i "\<Master_Log_File\>"| awk '{print $2}'`
RelayMasterLogFile=`$SLAVE_MYSQL_CMD -e "show slave status\G" |egrep -i "\<Relay_Master_Log_File\>"| awk '{print $2}'`
ReadMasterLogPos=`$SLAVE_MYSQL_CMD -e "show slave status\G" |egrep -i "\<Read_Master_Log_Pos\>"| awk '{print $2}'`
ExecMasterLogPos=`$SLAVE_MYSQL_CMD -e "show slave status\G" |egrep -i "\<Exec_Master_Log_Pos\>"| awk '{print $2}'`
REP_STATUS=`$SLAVE_MYSQL_CMD -e "show slave status\G"  |egrep "Slave_IO_Running|Slave_SQL_Running" |grep -c "Yes"`
 
# 主从复制状态检测
if [ $MasterLogFile == $RelayMasterLogFile  ] && [ $ReadMasterLogPos == $ExecMasterLogPos  ] && [ $REP_STATUS -eq 2 ];then
   action "[slave] status" /bin/true 
else
   action "[slave] status" /bin/false
   $SLAVE_MYSQL_CMD -e "show slave status\G"  >> $MASTER_STATUS_FILE
   exit 1
fi
 
