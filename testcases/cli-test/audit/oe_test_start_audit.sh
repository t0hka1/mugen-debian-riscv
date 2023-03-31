#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Date      :   2022/01/04
# @License   :   Mulan PSL v2
# @Desc      :   Start auditd, set the boot to start
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"


function pre_test() {
    LOG_INFO "Start environmental preparation."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -ne 0 ]; then  
        APT_INSTALL auditd
    fi
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    systemctl start auditd
    CHECK_RESULT $? 0 0 "Failed to start auditd service"
    systemctl status auditd | grep active
    CHECK_RESULT $? 0 0 "Failed to chkconfig auditd service with status enable"
    systemctl disable auditd
    systemctl status auditd | grep disable
    CHECK_RESULT $? 0 0 "Failed to chkconfig auditd service with status disable"
    systemctl enable auditd
    systemctl status auditd | grep enable
    CHECK_RESULT $? 0 0 "Failed to chkconfig auditd service with status enable"
    LOG_INFO "Finish testcase execution."
}
main "$@"
