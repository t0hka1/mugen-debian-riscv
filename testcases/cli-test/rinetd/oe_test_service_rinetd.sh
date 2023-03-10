#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author        :   wenjun
#@Contact       :   1009065695@qq.com
#@Date          :   2021-09-07
#@License       :   Mulan PSL v2
#@Desc          :   Test rinetd.service restart
#####################################
source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL rinetd 
    else 
        APT_INSTALL rinetd 
    fi
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution rinetd.service
    systemctl start rinetd.service
    systemctl reload rinetd.service
    CHECK_RESULT $? 0 0 "rinetd.service reload failed"
    systemctl status rinetd.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "rinetd.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    systemctl stop rinetd.service
    APT_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main "$@"

