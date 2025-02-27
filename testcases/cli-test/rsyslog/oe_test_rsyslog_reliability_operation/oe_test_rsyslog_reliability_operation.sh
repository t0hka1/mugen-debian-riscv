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
# @Author    :   wangshan
# @Contact   :   wangshan@163.com
# @Date      :   2020-08-03
# @License   :   Mulan PSL v2
# @Desc      :   restart/start/close operation is normal
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
	LOG_INFO "Start to prepare the test environment."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL rsyslog 
    else 
        APT_INSTALL rsyslog 
    fi
    LOG_INFO "End to prepare the test environment."
}


function run_test() {
    LOG_INFO "Start to run test."
    systemctl start rsyslog
    CHECK_RESULT $?
    systemctl status rsyslog 2>&1 | grep active
    CHECK_RESULT $?
    systemctl stop rsyslog
    CHECK_RESULT $?
    systemctl status rsyslog 2>&1 | grep inactive
    CHECK_RESULT $?
    systemctl restart rsyslog
    CHECK_RESULT $?
    systemctl status rsyslog 2>&1 | grep active
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

