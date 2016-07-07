#!/usr/bin/python
#coding=utf8
"""
# Author: Bill
# Created Time : 2016年05月09日 星期一 18时25分33秒

# File Name: bos_sample_conf.py
# Description:

"""
#!/usr/bin/env python
#coding=utf-8

#导入Python标准日志模块
import logging

#从Python SDK导入BOS配置管理模块以及安全认证模块
from baidubce.bce_client_configuration import BceClientConfiguration
from baidubce.auth.bce_credentials import BceCredentials

#设置BosClient的Host，Access Key ID和Secret Access Key
bos_host = "BOS_HOST"
access_key_id = "AK"
secret_access_key = "SK"

#设置日志文件的句柄和日志级别
logger = logging.getLogger('baidubce.services.bos.bosclient')
fh = logging.FileHandler("sample.log")
fh.setLevel(logging.DEBUG)

#设置日志文件输出的顺序、结构和内容
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s -
%(message)s')
fh.setFormatter(formatter)
logger.setLevel(logging.DEBUG)
logger.addHandler(fh)

#创建BceClientConfiguration
config = BceClientConfiguration(credentials=BceCredentials(access_key_id,secret_access_key),endpoint = bos_host)
                                                           secret_access_key),
                                endpoint = bos_host)''""''""""""
