#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   duanxuemin
# @Contact   :   duanxuemin_job@163.com
# @Date      :   2022-04-09
# @License   :   Mulan PSL v2
# @Desc      :   mysql-server command test
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    version_id=`cat /etc/os-release  | grep "VERSION_ID" | awk -F "=" {'print$NF'} | awk -F "\"" {'print$2'}`
    if [ ${version_id} = "20.03" ];then
        exit 0
    fi
    rm -rf /var/lib/mysql/*
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL mysql-server 
    else 
        APT_INSTALL mysql-server 
    fi
    systemctl start mysqld
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    systemctl status mysqld | grep running
    CHECK_RESULT $?
    mysql_ssl_rsa_setup --help | grep "mysql_ssl_rsa_setup"
    CHECK_RESULT $?
    mysql -e "show variables like 'have_ssl';" >test.txt
    CHECK_RESULT $?
    cat test.txt | sed -n 2p | awk '{print$2}' | grep "YES"
    CHECK_RESULT $?
    mysql_ssl_rsa_setup -v FALSE | grep "Success"
    CHECK_RESULT $?
    mysql_ssl_rsa_setup -V
    mysql_ssl_rsa_setup -V | grep -i "mysql_ssl_rsa_setup.*Ver"
    CHECK_RESULT $?
    mysql_ssl_rsa_setup -d /var/lib/mysql
    CHECK_RESULT $?
    mysql_ssl_rsa_setup -uid 123
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    rm -rf test.txt
    systemctl stop mysqld
    APT_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
