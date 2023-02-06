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
# @Date      :   2020/10/15
# @License   :   Mulan PSL v2
# @Desc      :   The usage of commands in swig package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    uname -r | grep 'oe\|an' 
    if [$? -eq 0]; then  
        DNF_INSTALL swig 
    else 
        APT_INSTALL swig 
    fi
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    swig -java -nocpperraswarn example.i
    CHECK_RESULT $?
    grep "erro" example_wrap.c
    CHECK_RESULT $? 1
    swig -java -nodefault example.i 2>&1 | grep "nodefault"
    CHECK_RESULT $?
    swig -java -nodefaultctor example.i
    CHECK_RESULT $?
    grep -i "defaultctor" example_wrap.c
    CHECK_RESULT $? 1
    swig -java -oh headfile example.i
    CHECK_RESULT $?
    grep "head" example_wrap.c
    CHECK_RESULT $?
    swig -java -nodirprot example.i
    CHECK_RESULT $?
    grep "dirprot" example_wrap.c
    CHECK_RESULT $? 1
    swig -java -noexcept example.i
    CHECK_RESULT $?
    grep "int fact(int);" example_wrap.c
    CHECK_RESULT $? 1
    swig -java -nofastdispatch example.i
    CHECK_RESULT $?
    grep -i "fast" example_wrap.c
    CHECK_RESULT $? 1
    swig -java -E example.i >result
    swig -java -nopreprocess result
    CHECK_RESULT $?
    grep -i "preprocess" example_wrap.c
    CHECK_RESULT $? 1
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    APT_REMOVE
    rm -rf $(ls | grep -vE ".sh|example.i")
    LOG_INFO "End to restore the test environment."
}

main "$@"
