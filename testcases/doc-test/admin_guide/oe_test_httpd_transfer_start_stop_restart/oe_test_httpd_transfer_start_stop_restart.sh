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
# @Date      :   2020.4-9
# @License   :   Mulan PSL v2
# @Desc      :   Httpd starts and stops and restarts the service
# #############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL httpd 
    else 
        APT_INSTALL httpd 
    fi
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    systemctl daemon-reload
    systemctl restart httpd
    CHECK_RESULT $?
    SLEEP_WAIT 8
    systemctl start httpd
    CHECK_RESULT $?
    SLEEP_WAIT 8
    systemctl status httpd | grep running
    CHECK_RESULT $?
    systemctl restart httpd
    CHECK_RESULT $?
    SLEEP_WAIT 8
    systemctl start httpd
    CHECK_RESULT $?
    SLEEP_WAIT 8
    systemctl status httpd | grep running
    CHECK_RESULT $?
    systemctl reload httpd
    CHECK_RESULT $?
    apachectl graceful
    CHECK_RESULT $?

    systemctl stop httpd
    systemctl status httpd | grep dead
    CHECK_RESULT $?
    systemctl disable httpd
    systemctl is-enabled httpd | grep disable
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    APT_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
