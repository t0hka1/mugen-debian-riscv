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
# @Desc      :   Profile lost / recovered
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL httpd 
    else 
        APT_INSTALL httpd 
    fi
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    systemctl restart httpd
    SLEEP_WAIT 9
    systemctl status httpd | grep running
    CHECK_RESULT $?
    mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf_bak
    systemctl restart httpd
    systemctl status httpd | grep running
    CHECK_RESULT $? 1
    mv /etc/httpd/conf/httpd.conf_bak /etc/httpd/conf/httpd.conf
    systemctl restart httpd.service
    SLEEP_WAIT 7
    systemctl start httpd
    SLEEP_WAIT 7
    systemctl status httpd | grep running
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    systemctl stop httpd
    APT_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
