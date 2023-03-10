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
# @Date      :   2020/10/23
# @License   :   Mulan PSL v2
# @Desc      :   The usage of ocamlc.out under ocaml package
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
    cp -rf ../a.c ../hello.ml ../hello_stubs.c ../example.ml ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamlc.opt --help | grep "ocamlc"
    CHECK_RESULT $?
    ocamlc.opt -a -o a.o a.c
    CHECK_RESULT $?
    grep -aE "Caml|a.o" a.o
    CHECK_RESULT $?
    ocamlc.opt -custom -o hello.exe hello.ml hello_stubs.c
    CHECK_RESULT $?
    ./hello.exe | grep "Hello world!"
    CHECK_RESULT $?
    ocamlc.opt -annot example.ml
    CHECK_RESULT $?
    ./a.out | grep "6"
    CHECK_RESULT $?
    ocamlc.opt -bin-annot example.ml
    CHECK_RESULT $?
    ocamlcmt -info example.cmt | grep "module name" -A 15
    CHECK_RESULT $?
    ocamlc.opt -c a.c
    CHECK_RESULT $?
    grep -ai "editor" a.o
    CHECK_RESULT $?
    ocamlc.opt -color auto a.c
    CHECK_RESULT $?
    grep -a "rela.eh_frame" a.o
    CHECK_RESULT $?
    ocamlc.opt -absname hello.ml >result 2>&1
    CHECK_RESULT $? 0 1
    grep "/hello.ml" result
    CHECK_RESULT $?
    ocamlc.opt -config a.c | grep -E "version|ocamlc" -A 55
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    APT_REMOVE
    rm -rf a.c a.o ./example* ./hello* result
    LOG_INFO "End to restore the test environment."
}

main "$@"
