#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author        :   zhujinlong
#@Contact       :   zhujinlong@163.com
#@Date          :   2020-11-23
#@License       :   Mulan PSL v2
#@Desc          :   node.js is JavaScript running on the server side.
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    DNF_INSTALL nodejs
    echo 'console.log("Hello,Kitty");' >my.js
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    node --track-heap-objects my.js | grep 'Hello,Kitty'
    CHECK_RESULT $?
    node --use-bundled-ca my.js | grep 'Hello,Kitty'
    CHECK_RESULT $?
    node --use-openssl-ca my.js | grep 'Hello,Kitty'
    CHECK_RESULT $?
    node --v8-options | grep 'Options:'
    CHECK_RESULT $?
    node --zero-fill-buffers my.js | grep 'Hello,Kitty'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    DNF_REMOVE
    rm -f my.js
    LOG_INFO "End to restore the test environment."
}

main "$@"
