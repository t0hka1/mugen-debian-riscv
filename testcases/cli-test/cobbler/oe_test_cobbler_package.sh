#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

###################################
#@Author    :   qinhaiqi
#@Contact   :   2683064908@qq.com
#@Date      :   2022/2/16
#@License   :   Mulan PSL v2
#@Desc      :   Test "cobbler package" command
###################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    uname -r | grep 'oe\|an' 
    if [ $? -eq 0 ]; then  
        DNF_INSTALL "cobbler httpd" 
    else 
        APT_INSTALL "cobbler httpd" 
    fi
    systemctl start httpd
    systemctl start cobblerd
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run testcase."
    cobbler package add --name=OpenEuler1
    CHECK_RESULT $? 0 0 "Failed option: package add"
    cobbler package copy --name=OpenEuler1 --newname=OpenEuler2
    CHECK_RESULT $? 0 0 "Failed option: package copy"
    cobbler package list | grep "OpenEuler2"
    CHECK_RESULT $? 0 0 "Failed option: package copy"
    cobbler package edit --name=openEuler1 --owners=tom
    CHECK_RESULT $? 0 0 "Failed option: package edit"
    cobbler package report --name=openEuler1 | grep "tom"
    CHECK_RESULT $? 0 0 "Failed option: package edit"
    cobbler package list | grep "OpenEuler"
    CHECK_RESULT $? 0 0 "Failed option: package list"
    cobbler package find | grep "OpenEuler"
    CHECK_RESULT $? 0 0 "Failed option: package find"
    cobbler package remove --name=OpenEuler1
    CHECK_RESULT $? 0 0 "Failed option: package remove"
    cobbler package list | grep "OpenEuler1"
    CHECK_RESULT $? 0 1 "Failed option: package remove"
    cobbler package rename --name=OpenEuler2 --newname=OpenEuler3
    CHECK_RESULT $? 0 0 "Failed option: package rename"
    cobbler package list | grep "OpenEuler3"
    CHECK_RESULT $? 0 0 "Failed option: package rename"
    cobbler package report --name=OpenEuler3 | grep "Name"
    CHECK_RESULT $? 0 0 "Failed option: package report"
    LOG_INFO "End to run testcase."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    systemctl stop httpd
    systemctl stop cobblerd
    APT_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
