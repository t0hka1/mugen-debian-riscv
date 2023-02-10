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
# @Author    :   liujingjing
# @Contact   :   liujingjing25812@163.com
# @Date      :   2020/5/14
# @License   :   Mulan PSL v2
# @Desc      :   Easymock combined with Maven to simulate the unimplemented interface
# ############################################

source "../common/common_easymock.sh"
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    uname -r | grep 'oe\|an' 
    if [ $? -eq 0 ]; then  
        DNF_INSTALL maven 
    else 
        APT_INSTALL maven 
    fi
    mkdir libs
    cp -rf "$(rpm -ql junit | grep junit.jar)" "$(rpm -ql easymock | grep easymock.jar)" "$(rpm -ql hamcrest | grep core.jar)" libs
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    mvn test | grep "Tests run: 3, Failures: 0, Errors: 0, Skipped: 0"$'\n'"BUILD SUCCESS"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    clear_env
    rm -rf /root/.m2
    LOG_INFO "End to restore the test environment."
}

main "$@"
