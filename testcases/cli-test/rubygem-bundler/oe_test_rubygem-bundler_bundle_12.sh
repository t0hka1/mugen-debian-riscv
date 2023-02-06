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
    if [$? -eq 0]; then  
        DNF_INSTALL rubygem-bundler 
    else 
        APT_INSTALL rubygem-bundler 
    fi
    bundle init
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    bundle lock --full-index && test -f Gemfile.lock
    CHECK_RESULT $? 0 0 "Check bundle lock --minor failed."
    bundle lock --add-platform test && test -f Gemfile.lock
    CHECK_RESULT $? 0 0 "Check bundle lock --minor failed."
    bundle lock --remove-platform test && test -f Gemfile.lock
    CHECK_RESULT $? 0 0 "Check bundle lock --minor failed."
    bundle lock --major && test -f Gemfile.lock
    CHECK_RESULT $? 0 0 "Check bundle lock --minor failed."
    bundle lock --strict && test -f Gemfile.lock
    CHECK_RESULT $? 0 0 "Check bundle lock --minor failed."
    bundle lock --conservative && test -f Gemfile.lock
    CHECK_RESULT $? 0 0 "Check bundle lock --minor failed."
    bundle platform | grep "platform is:"
    CHECK_RESULT $? 0 0 "Check bundle platform failed."
    bundle platform --ruby | grep "No ruby"
    CHECK_RESULT $? 0 0 "Check bundle platform --ruby failed."
    bundle cache
    CHECK_RESULT $? 0 0 "Check bundle cache failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf Gemfile Gemfile.lock .bundle
    APT_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
