#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-4-9
# @License   :   Mulan PSL v2
# @Desc      :   Use mysqldump to copy data between two databases
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    uname -r | grep 'oe\|an' 
    if [ $? -eq 0 ]; then  
        DNF_INSTALL mariadb-server 
    else 
        APT_INSTALL mariadb-server 
    fi
    rm -rf /var/lib/mysql/*
    systemctl start mariadb.service
    systemctl status mariadb.service | grep running || exit 1
    mysqladmin -uroot password ${NODE1_PASSWORD}
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    expect -c "
        set timeout 30
        spawn mysqldump -u root -p  --databases mysql  -r /home/mysql.sql
        expect {
            \"Enter*\" {send \"${NODE1_PASSWORD}\r\"}
        }
        expect eof
    "
    find /home/mysql.sql
    CHECK_RESULT $?
    expect -c "
        set timeout 10
        log_file testlog
        spawn mysql -u root -p
        expect {
            \"Enter*\" { send \"${NODE1_PASSWORD}\r\";
            expect \"Maria*\" { send \"create database target_db;\r\"}
            expect \"Maria*\" { send \"use target_db;\r\"}
            expect \"Maria*\" { send \"source /home/mysql.sql;\r\"}
            expect \"Maria*\" { send \"exit\r\"}
        }
    }
    expect eof
    "
    grep -iE 'error|fail|while executing' testlog
    CHECK_RESULT $? 1
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /home/mysql.sql testlog /var/lib/mysql
    APT_REMOVE
    LOG_INFO "End to restore the test environment."
}

main $@
