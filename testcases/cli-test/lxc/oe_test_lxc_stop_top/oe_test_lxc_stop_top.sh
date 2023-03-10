#!/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   wanxiaofei_wx5323714
# @Contact   :   wanxiaofei4@huawei.com
# @Date      :   2020-08-02
# @License   :   Mulan PSL v2
# @Desc      :   verification lxc‘s attach command
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL "lxc lxc-devel lxc-libs lxcfs lxcfs-tools tar busybox" 
    else 
        APT_INSTALL "lxc lxc-devel lxc-libs lxcfs lxcfs-tools tar busybox" 
    fi
    version=$(rpm -qa lxc | awk -F '-' '{print $2}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    lxc-create -t /usr/share/lxc/templates/lxc-busybox -n myEuler1
    CHECK_RESULT $? 0 0 "Failed to set up container."
    lxc-stop --help 2>&1 | grep -i "Usage"
    CHECK_RESULT $? 0 0 "Check lxc-stop --help failed."
    lxc-stop --usage 2>&1 | grep -i "Usage: lxc-stop"
    CHECK_RESULT $? 0 0 "Check lxc-stop --usage failed."
    lxc-stop --version | grep $version
    CHECK_RESULT $? 0 0 "Check lxc-stop --version failed."
    lxc-start -n myEuler1
    CHECK_RESULT $? 0 0 "Check lxc-start -n failed."
    lxc-stop -n myEuler1
    CHECK_RESULT $? 0 0 "Check lxc-stop -n failed."
    lxc-info myEuler1 | grep State | grep STOPPED
    CHECK_RESULT $? 0 0 "Check lxc-info failed."

    lxc-top --help 2>&1 | grep -i "Usage"
    CHECK_RESULT $? 0 0 "Check lxc-top --help failed."
    lxc-top --usage 2>&1 | grep -i "Usage: lxc-top"
    CHECK_RESULT $? 0 0 "Check lxc-top --usage failed."
    lxc-top --version | grep $version
    CHECK_RESULT $? 0 0 "Check lxc-top --version failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the tet environment."
    lxc-stop myEuler1
    lxc-destroy myEuler1
    APT_REMOVE
    LOG_INFO "End to restore the tet environment."
}

main "$@"
