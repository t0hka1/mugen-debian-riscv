#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   wenjun
# @Contact   :   1009065695@qq.com
# @Date      :   2021/11/11
# @License   :   Mulan PSL v2
# @Desc      :   Test trafficserver.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL trafficserver 
    else 
        APT_INSTALL trafficserver 
    fi
    service=trafficserver.service
    log_time=$(date '+%Y-%m-%d %T')
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    systemctl restart "${service}"
    CHECK_RESULT $? 0 0 "${service} restart failed"
    SLEEP_WAIT 15
    systemctl status "${service}" | grep "Active: active"
    CHECK_RESULT $? 0 0 "${service} restart failed"
    systemctl stop "${service}"
    CHECK_RESULT $? 0 0 "${service} stop failed"
    SLEEP_WAIT 15
    systemctl status "${service}" | grep "Active: inactive"
    CHECK_RESULT $? 0 0 "${service} stop failed"
    systemctl start "${service}"
    CHECK_RESULT $? 0 0 "${service} start failed"
    SLEEP_WAIT 15
    systemctl status "${service}" | grep "Active: active"
    CHECK_RESULT $? 0 0 "${service} start failed"
    test_enabled "${service}"
    journalctl --since "${log_time}" -u "${service}" | grep -i "fail\|error" | grep -v -i "DEBUG\|INFO\|WARNING"
    CHECK_RESULT $? 0 1 "There is an error message for the log of ${service}"
    systemctl reload "${service}"
    CHECK_RESULT $? 0 0 "${service} reload failed"
    systemctl status "${service}" | grep "Active: active"
    CHECK_RESULT $? 0 0 "${service} reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop "${service}"
    APT_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
