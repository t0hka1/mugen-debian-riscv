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
# @Desc      :   Test snmpd.service restart
# #############################################

source "../common/common_lib.sh"
    
function pre_test() {
    LOG_INFO "Start environmental preparation."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL net-snmp 
    else 
        APT_INSTALL net-snmp 
    fi
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution snmpd.service
    systemctl start snmpd.service
    sed -i 's\ExecStart=/usr/sbin/snmpd\ExecStart=/usr/sbin/snmpd -V\g' /usr/lib/systemd/system/snmpd.service
    systemctl daemon-reload
    systemctl reload snmpd.service
    CHECK_RESULT $? 0 0 "snmpd.service reload failed"
    systemctl status snmpd.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "snmpd.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/usr/sbin/snmpd -V\ExecStart=/usr/sbin/snmpd\g' /usr/lib/systemd/system/snmpd.service
    systemctl daemon-reload
    systemctl reload snmpd.service
    systemctl stop snmpd.service
    APT_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
