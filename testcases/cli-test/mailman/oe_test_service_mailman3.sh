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
# @Desc      :   Test mailman.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL "mailman postfix" 
    else 
        APT_INSTALL "mailman postfix" 
    fi
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution mailman3.service
    systemctl start mailman3.service
    sed -i 's\ExecStart=/usr/bin/mailman3 start --force\ExecStart=/usr/bin/mailman3 start\g' /usr/lib/systemd/system/mailman3.service
    systemctl daemon-reload
    systemctl reload mailman3.service
    CHECK_RESULT $? 0 0 "mailman3.service reload failed"
    systemctl status mailman3.service | grep "Active: active"
    CHECK_RESULT $? 0 0 "mailman3.service reload causes the service status to change"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i 's\ExecStart=/usr/bin/mailman3 start\ExecStart=/usr/bin/mailman3 start --force\g' /usr/lib/systemd/system/mailman3.service
    systemctl daemon-reload
    systemctl reload mailman3.service
    systemctl stop mailman3.service
    /usr/lib/mailman/bin/rmlist mailman3
    APT_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
