# config

<!-- vim-markdown-toc GFM -->
* [备份数据库到本地目录](#备份数据库到本地目录)
* [备份数据库到bos](#备份数据库到bos)

<!-- vim-markdown-toc -->

### 备份数据库到本地目录

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
bos=OFF
```
### 备份数据库到bos

(1)修改配置文件
/opt/X_crontab/mysqlbackup/backupdb.config

```
bos=ON
```
(2)修改配置文件
/opt/X_crontab/mysqlbackup/bce/bos_conf.py

```
HOST = ''
AK = ''
SK = ''
```
