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
# @Desc      :   Test virtnetworkd.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL libvirt-daemon-driver-network 
    else 
        APT_INSTALL libvirt-daemon-driver-network 
    fi
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution virtnetworkd.service
    systemctl start virtnetworkd.service
    sed -i 's\ExecStart=/usr/sbin/virtnetworkd\ExecStart=/usr/sbin/virtnetworkd -v\g' /usr/lib/systemd/system/virtnetworkd.service
    systemctl daemon-reload
    systemctl reload virtnetworkd.service
    CHECK_RESULT $? 0 0 "virtnetworkd.service reload failed"
    systemctl status virtnetworkd.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "virtnetworkd.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/usr/sbin/virtnetworkd -v\ExecStart=/usr/sbin/virtnetworkd\g' /usr/lib/systemd/system/virtnetworkd.service
    systemctl daemon-reload
    systemctl reload virtnetworkd.service
    systemctl stop virtnetworkd.service
    APT_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
