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
# @Date      :   2020/10/30
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in libwbxml package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    uname -r | grep 'oe\|an' 
    if [ $? -eq 0 ]; then  
        DNF_INSTALL libwbxml 
    else 
        APT_INSTALL libwbxml 
    fi
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    xml2wbxml -o output.wbxml input.xml
    CHECK_RESULT $?
    test -f output.wbxml
    CHECK_RESULT $?
    cp output.wbxml input.wbxml
    xml2wbxml -k -n -v 1.1 -o output.wbxml input.xml
    CHECK_RESULT $?
    strings output.wbxml | grep "EFGH"
    CHECK_RESULT $? 1
    xml2wbxml -a input.xml -o output.wbxml
    CHECK_RESULT $?
    strings output.wbxml | grep "MICROSOFT"
    CHECK_RESULT $? 1
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    APT_REMOVE
    del_file=$(ls | grep -vE ".sh|input.xml")
    rm -rf ${del_file}
    LOG_INFO "End to restore the test environment."
}

main "$@"
