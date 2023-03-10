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
#@Author    	:   meitingli
#@Contact   	:   244349477@qq.com
#@Date      	:   2021-08-02
#@License   	:   Mulan PSL v2
#@Desc      	:   Take the test gnome-shell
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the database config."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL "gnome-shell elinks lynx" 
    else 
        APT_INSTALL "gnome-shell elinks lynx" 
    fi
    OLD_LANG=$LANG
    export LANG="en_US.UTF-8"
    LOG_INFO "End to prepare the database config."
}

function run_test() {
    LOG_INFO "Start to run test."
    gnome-shell --list-modes | grep -i "user"
    CHECK_RESULT $? 0 0 "Check gnome-shell --list-mode failed."
    gnome-shell --version | grep -i "GNOME Shell"
    CHECK_RESULT $? 0 0 "Check gnome-shell --version failed."
    gnome-shell -h | grep -i "option"
    CHECK_RESULT $? 0 0 "Check gnome-shell -h failed."
    gnome-shell --help-all | grep -i "option"
    CHECK_RESULT $? 0 0 "Check gnome-shell --help-all failed."
    gnome-shell-perf-tool --version | grep -i "GNOME Shell"
    CHECK_RESULT $? 0 0 "Check gnome-shell-perf-tool --version failed."
    gnome-shell-perf-tool -h | grep -i "options"
    CHECK_RESULT $? 0 0 "Check gnome-shell-perf-tool -h failed."
    gnome-shell-extension-tool -h | grep -i "options"
    CHECK_RESULT $? 0 0 "Check gnome-shell-extension-tool -h failed."
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    export LANG=${OLD_LANG}
    APT_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
