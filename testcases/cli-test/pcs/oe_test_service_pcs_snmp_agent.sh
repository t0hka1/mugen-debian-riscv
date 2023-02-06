#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Date      :   2021/12/30
# @License   :   Mulan PSL v2
# @Desc      :   Test pcs_snmp_agent.service restart
# #############################################

source "../common/ha.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    service=pcs_snmp_agent.service
    ha_pre
    uname -r | grep 'oe\|an' 
    if [$? -eq 0]; then  
        DNF_INSTALL pcs-snmp 
    else 
        APT_INSTALL pcs-snmp 
    fi
    echo "master agentx
view systemview included .1.3.6.1.4.1.32723.100" >> /etc/snmp/snmpd.conf
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution "${service}"
    test_reload "${service}"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop "${service}"
    sed -i '/master agentx/d' /etc/snmp/snmpd.conf
    sed -i '/view systemview included/d' /etc/snmp/snmpd.conf
    APT_REMOVE
    ha_post
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
