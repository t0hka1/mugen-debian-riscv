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
# @Desc      :   Test proftpd.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL proftpd 
    else 
        APT_INSTALL proftpd 
    fi
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution proftpd.service
    systemctl start proftpd.service
    sed -i 's\ExecStart = /usr/sbin/proftpd\ExecStart = /usr/sbin/proftpd -q\g' /usr/lib/systemd/system/proftpd.service
    systemctl daemon-reload
    systemctl reload proftpd.service
    CHECK_RESULT $? 0 0 "proftpd.service reload failed"
    systemctl status proftpd.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "proftpd.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart = /usr/sbin/proftpd -q\ExecStart = /usr/sbin/proftpd\g' /usr/lib/systemd/system/proftpd.service
    systemctl daemon-reload
    systemctl reload proftpd.service
    systemctl stop proftpd.service
    APT_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
