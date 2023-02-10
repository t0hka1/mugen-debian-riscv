#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   Use chronyc to control chronyd
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    uname -r | grep 'oe\|an' 
    if [ $? -eq 0 ]; then  
        DNF_INSTALL "chrony" 
    else 
        APT_INSTALL "chrony expect"     
    fi
    systemctl start chronyd
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    systemctl status chronyd | grep running
    CHECK_RESULT $?
    expect -d <<ENF0
    spawn chronyc
    log_file testlog
    expect "chronyc>"
    send "help\\r"
    expect "chronyc>"   
    send "sourcestats -v\\r"
    expect "chronyc>"              
    send "quit\\r"
ENF0
    CHECK_RESULT $?
    grep -i Manual testlog
    CHECK_RESULT $?

    grep "Name/IP Address" testlog
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf ./testlog
    systemctl stop chronyd
    APT_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
