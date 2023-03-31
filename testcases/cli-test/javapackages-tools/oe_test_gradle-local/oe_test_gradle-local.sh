#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/26
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of gradle command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL gradle 
    else 
        APT_INSTALL gradle
    fi
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    gradle --help | grep "-"
    CHECK_RESULT $?
    gradle -v | grep -i "Gradle"
    CHECK_RESULT $?
    gradle
    CHECK_RESULT $?
    gradle extend | grep -E "BUILD SUCCESSFUL|extend"
    CHECK_RESULT $?
    gradle base | grep -E "BUILD SUCCESSFUL|base"
    CHECK_RESULT $?
    gradle base dolast | grep -E "base|dolast|BUILD SUCCESSFUL"
    CHECK_RESULT $?
    gradle base dolast -x dolast | grep "dolast"
    CHECK_RESULT $? 1
    gradle base --rerun-tasks
    CHECK_RESULT $?
    gradle base --continue
    CHECK_RESULT $?
    gradle -q base | grep "I am base!"
    CHECK_RESULT $?
    gradle -w base
    CHECK_RESULT $?
    gradle -i base | grep -E "Starting Build|All projects evaluated|Tasks to be executed: \[task ':base'\]"
    CHECK_RESULT $?
    gradle base --console plain
    CHECK_RESULT $?
    gradle base --console rich
    CHECK_RESULT $?
    gradle base --status | grep -E "PID|STATUS|INFO|$(gradle -v | grep "Gradle" | awk '{print $2}')"
    CHECK_RESULT $?
    expect <<EOF
        spawn gradle base --scan
        expect "" {send "yes\r"}
        expect eof
EOF
    gradle base extend dolast --parallel
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf .gradle
    APT_REMOVE
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
