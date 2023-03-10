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
# @Author    :   huangrong
# @Contact   :   1820463064@qq.com
# @Date      :   2020/10/23
# @License   :   Mulan PSL v2
# @Desc      :   Test obsservice.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    flag=false
    if [ $(getenforce | grep Enforcing) ]; then
        setenforce 0
        flag=true
    fi
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL obs-server 
    else 
        APT_INSTALL obs-server 
    fi
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution obsservice.service
    systemctl start obsservice.service
    sed -i 's\ExecStart=/usr/lib/obs/server/bs_service --logfile src_service.log\ExecStart=/usr/lib/obs/server/bs_service\g' /usr/lib/systemd/system/obsservice.service
    systemctl daemon-reload
    systemctl reload obsservice.service
    CHECK_RESULT $? 0 0 "obsservice.service  reload failed"
    systemctl status obsservice.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "obsservice.service  reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/usr/lib/obs/server/bs_service\ExecStart=/usr/lib/obs/server/bs_service --logfile src_service.log\g' /usr/lib/systemd/system/obsservice.service
    systemctl daemon-reload
    systemctl reload obsservice.service
    systemctl stop obsservice.service
    APT_REMOVE
    if [ ${flag} = 'true' ]; then
        setenforce 1
    fi
    LOG_INFO "Finish environment cleanup!"
}

main "$@"

