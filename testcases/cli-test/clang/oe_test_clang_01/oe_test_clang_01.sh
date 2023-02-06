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
#@Author    	:   guochenyang
#@Contact   	:   377012421@qq.com
#@Date      	:   2020-10-10 09:30:43
#@License       :   Mulan PSL v2
#@Desc      	:   verification clang‘s command
#####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    uname -r | grep 'oe\|an' 
    if [$? -eq 0]; then  
        DNF_INSTALL clang 
    else 
        APT_INSTALL clang 
    fi
    cp -r ../common ./tmp
    cd ./tmp
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    clang -ccc-print-phases test.c
    CHECK_RESULT $?
    clang -rewrite-objc test.c
    CHECK_RESULT $?
    clang -#\#\# test.c -o main
    CHECK_RESULT $?
    clang -E test.c
    CHECK_RESULT $?
    clang -O3 -S -fobjc-arc -emit-llvm test.c -o test.ll
    CHECK_RESULT $?
    test -f test.ll
    CHECK_RESULT $?
    clang -fmodules -fsyntax-only -Xclang -ast-dump test.c
    CHECK_RESULT $?
    clang -fmodules -fsyntax-only -Xclang -dump-tokens test.c
    CHECK_RESULT $?
    clang -S -fobjc-arc test.c -o test.s
    CHECK_RESULT $?
    test -f test.s
    CHECK_RESULT $?
    clang -fmodules -c test.c -o test.o
    CHECK_RESULT $?
    test -f test.o
    CHECK_RESULT $?
    clang test.o -o test
    CHECK_RESULT $?
    test -f test
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}
function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf ./tmp
    APT_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
