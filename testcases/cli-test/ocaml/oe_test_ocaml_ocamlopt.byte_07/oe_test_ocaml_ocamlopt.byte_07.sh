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
# @Date      :   2020/11/9
# @License   :   Mulan PSL v2
# @Desc      :   The usage of ocamlopt.byte under ocaml package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL ocaml 
    else 
        APT_INSTALL ocaml 
    fi
    cp ../example.ml ../a.c ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamlopt.byte -config a.c | grep -E "version|ocamlc" -A 55
    CHECK_RESULT $?
    ocamlopt.byte -dtypes example.ml
    CHECK_RESULT $?
    grep -A 3 "type" example.annot
    CHECK_RESULT $?
    ocamlopt.byte -for-pack P -c example.ml
    CHECK_RESULT $?
    grep -a "camlP__Example" example.o
    CHECK_RESULT $?
    ocamlopt.byte -g a.c
    CHECK_RESULT $?
    objdump -x a.o | grep debug
    CHECK_RESULT $?
    ocamlopt.byte -nostdlib a.c
    CHECK_RESULT $?
    objdump -x a.o | grep stdlib
    CHECK_RESULT $? 1
    cp ../hello_stubs.c ./
    ocamlopt.byte -i hello_stubs.c
    CHECK_RESULT $?
    objdump -x hello_stubs.o | grep "caml_print_hello"
    CHECK_RESULT $?
    ocamlopt.byte -I +/usr/lib64/ocaml hello_stubs.c
    CHECK_RESULT $?
    grep -ai "hello world" hello_stubs.o
    CHECK_RESULT $?
    cp example.ml exampletest
    ocamlopt.byte -impl exampletest
    CHECK_RESULT $?
    grep -ai "exampletest" exampletest.cmi
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    APT_REMOVE
    rm -rf ./a* ./example* ./hello*
    LOG_INFO "End to restore the test environment."
}

main "$@"
