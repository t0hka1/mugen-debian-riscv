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
    bundle install --no-full-index | grep "Bundle complete"
    CHECK_RESULT $? 0 0 "Check bundle install --no-full-index failed."
    bundle install --gemfile Gemfile | grep "Bundle complete"
    CHECK_RESULT $? 0 0 "Check bundle install --gemfile failed."
    bundle install -j 2 | grep "Bundle complete"
    CHECK_RESULT $? 0 0 "Check bundle install -j failed."
    bundle install --local | grep "Bundle complete"
    CHECK_RESULT $? 0 0 "Check bundle install --local failed."
    bundle install --no-cache | grep "Bundle complete"
    CHECK_RESULT $? 0 0 "Check bundle install --no-cache failed."
    bundle install --force | grep "Bundle complete"
    CHECK_RESULT $? 0 0 "Check bundle install --force failed."
    bundle install --no-prune | grep "Bundle complete"
    CHECK_RESULT $? 0 0 "Check bundle install --no-prune failed."
    bundle install --path /opt/ | grep "opt"
    CHECK_RESULT $? 0 0 "Check bundle install --path failed."
    bundle install --quiet | grep "Bundle complete"
    CHECK_RESULT $? 1 0 "Check bundle install --quiet failed."
    bundle install --standalone | grep "Bundle complete"
    CHECK_RESULT $? 0 0 "Check bundle install --clean failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf Gemfile .bundle
    APT_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
