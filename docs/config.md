# config

修改配置文件

/opt/X_crontab/mysqlbackup/backupdb.config

```
db_dump=mysqldump
db_mysql=mysql
# 数据库账号
mysql_account=root
# 数据库密码
mysql_password=
# 数据库地址
db_addr=127.0.0.1
# 数据库端口
db_port=3306

# 本地备份目录
back_dir=/data/mysqlbackup
# 需要备份的数据库
db_list=database1|database2|database3
log_dir=/data/mysqlbackup/logs
```
