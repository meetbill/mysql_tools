# Copyright (c) 2014 Baidu.com, Inc. All Rights Reserved
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.
"""
Samples for bos client.
"""

import os
import sys
import getopt

import bos_conf
from baidubce import exception
from baidubce.services.bos import canned_acl
from baidubce.services.bos.bos_client import BosClient
import logging

def upload_file(key,file_name):
    logging.basicConfig(level=logging.DEBUG,
		format='%(asctime)s%(filename)s[line:%(lineno)d] %(levelname)s%(message)s',
		datefmt='%a,%d %b %Y %H:%M:%S',
		filename='/tmp/bos.log',
		filemode='a')
    __logger = logging.getLogger(__name__)
    bucket_name = 'mysqlbackup'
    ######################################################################################################
    #            bucket operation samples
    ######################################################################################################

    # create a bos client
    bos_client = BosClient(bos_conf.config)

    # check if bucket exists
    #if not bos_client.does_bucket_exist(bucket_name):
    #    bos_client.create_bucket(bucket_name)

    ######################################################################################################
    #            object operation samples
    ######################################################################################################

    # put a file as object
    bos_client.put_object_from_file(bucket_name, key, file_name)

def Usage():
    print 'PyTest.py usage:'
    print '-h,--help: print help message.'
    print '-v, --version: print script version'
    print '--key: key '
    print '--file: file'

def main(argv):
    try:
        opts, args = getopt.getopt(argv[1:], 'hvo:', ['output=', 'key=', 'file='])
        db_key=""
        db_file=""
        # opts [('-o', 'wang')]
    except getopt.GetoptError, err:
        print str(err)
        Usage()
        sys.exit(2)
    for o, a in opts:
        if o in ('-h', '--help'):
            Usage()
            sys.exit(1)
        elif o in ('-v', '--version'):
            Version()
            sys.exit(0)
        elif o in ('--key',):
            db_key=a
        elif o in ('--file',):
            db_file=a
        else:
            print 'unhandled option'
            sys.exit(3)
    if (db_key and db_file): 
        upload_file(db_key,db_file)

if __name__ == '__main__':
    main(sys.argv)
