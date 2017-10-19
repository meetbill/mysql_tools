## mysql_tools

> * 备份工具，备份到本地目录
>   * 每日定时备份
>   * 针对设置的库进行备份
>   * 定期清理过期备份
> * 修复工具，mysql 主从异常后修复(测试)

## 备份工具

> * [0 安装](docs/install.md)  
> * [1 配置](docs/config.md)  

## 修复工具

> * [修复工具使用](https://github.com/BillWang139967/mysql_tools/wiki/repair_tools)

## 版本

* v1.0.4，2017-10-19，更新：修正定时任务部分
* v1.0.3，2017-08-30，更新：(1)修复文件夹加时分秒后，定时删除历史目录时无法匹配到的问题 (2)每个数据库备份成功或失败都会加上时间戳，以方便后期功能实现
* v1.0.2，2017-08-24，更新：(1)创建的文件夹名称会精确到时分秒 (2)日志中会输出版本号。
* v1.0.1，2015-05-14，新增：发布初始版本。

## 参加步骤

* 在 GitHub 上 `fork` 到自己的仓库，然后 `clone` 到本地，并设置用户信息。
```
$ git clone https://github.com/BillWang139967/mysql_tools.git
$ cd mysql_tools
$ git config user.name "yourname"
$ git config user.email "your email"
```
* 修改代码后提交，并推送到自己的仓库。
```
$ #do some change on the content
$ git commit -am "Fix issue #1: change helo to hello"
$ git push
```
* 在 GitHub 网站上提交 pull request。
* 定期使用项目仓库内容更新自己仓库内容。
```
$ git remote add upstream https://github.com/BillWang139967/mysql_tools.git
$ git fetch upstream
$ git checkout master
$ git rebase upstream/master
$ git push -f origin master
```
