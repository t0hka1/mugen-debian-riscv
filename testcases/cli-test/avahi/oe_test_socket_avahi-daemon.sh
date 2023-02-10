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
# @Author    :   zengcongwei
# @Contact   :   735811396@qq.com
# @Date      :   2020/12/29
# @License   :   Mulan PSL v2
# @Desc      :   Test avahi-daemon.socket restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    uname -r | grep 'oe\|an' 
    if [ $? -eq 0 ]; then  
        DNF_INSTALL avahi 
    else 
        APT_INSTALL avahi 
    fi
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    test_execution avahi-daemon.socket
    systemctl start avahi-daemon.socket
    systemctl reload avahi-daemon.socket 2>&1 | grep "Job type reload is not applicable for unit avahi-daemon.socket"
    CHECK_RESULT $?
    systemctl status avahi-daemon.socket | grep "Active: active"
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    APT_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
