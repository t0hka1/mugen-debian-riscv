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
# @Author    :   wangshan
# @Contact   :   wangshan@163.com
# @Date      :   2021-11-01
# @License   :   Mulan PSL v2
# @Desc      :   exrstdattr
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    uname -r | grep 'oe\|an' 
    if [ $? -eq 0 ]; then  
        DNF_INSTALL rubygem-bundler 
    else 
        APT_INSTALL rubygem-bundler 
    fi
    bundle init
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    bundle list | grep "Gemfile"
    CHECK_RESULT $? 0 0 "Check bundle list failed."
    bundle list --name-only | grep "Gemfile"
    CHECK_RESULT $? 0 0 "Check list --name-only failed."
    bundle list --paths | grep "Gemfile"
    CHECK_RESULT $? 0 0 "Check list --paths failed."
    bundle plugin | grep "Commands:"
    CHECK_RESULT $? 0 0 "Check bundle plugin failed."
    bundle plugin list | grep "plugins installed"
    CHECK_RESULT $? 0 0 "Check bundle plugin list failed."
    bundle plugin help list | grep "Usage:"
    CHECK_RESULT $? 0 0 "Check bundle plugin help failed."
    bundle clean | grep "Cleaning all the gems on your system is dangerous"
    CHECK_RESULT $? 1 0 "Check bundle clean failed."
    bundle clean --dry-run
    CHECK_RESULT $? 0 0 "Check bundle clean --dry-run failed."
    bundle clean --force
    CHECK_RESULT $? 0 0 "Check bundle  clean --force failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf Gemfile .bundle
    APT_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
