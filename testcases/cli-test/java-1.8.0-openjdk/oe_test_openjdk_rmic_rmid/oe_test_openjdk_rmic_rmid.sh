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
# @Author    :   wanxiaofei_wx5323714
# @Contact   :   wanxiaofei4@huawei.com
# @Date      :   2020-08-02
# @License   :   Mulan PSL v2
# @Desc      :   verification openjdk‘s command
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    uname -r | grep 'oe\|an' 
    if [ $? -eq 0 ]; then  
        DNF_INSTALL java-1.8.0-openjdk* 
    else 
        APT_INSTALL java-1.8.0-openjdk* 
    fi
    cp ../common/Hello.java .
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rmic -help | grep Usage
    CHECK_RESULT $?
    rmid -help 2>&1 | grep Usage
    CHECK_RESULT $?
    rmid -port 1111 -log portlog &
    SLEEP_WAIT 3
    rmid -stop -port 1111
    CHECK_RESULT $?
    find portlog
    CHECK_RESULT $?

    rmiregistry -h 2>&1 | grep Usage
    CHECK_RESULT $?

    schemagen -help | grep Usage
    CHECK_RESULT $?
    schemagen -version | grep 'schemagen [0-9]'
    CHECK_RESULT $?
    schemagen -fullversion | grep 'schemagen full version'
    CHECK_RESULT $?

    serialver 2>&1 | grep use
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Need't to restore the tet environment."
    APT_REMOVE
    rm -rf Hello.* portlog
    LOG_INFO "End to restore the test environment."
}

main "$@"
