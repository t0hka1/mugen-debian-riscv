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
# @Desc      :   The usage of ocamlopt.opt under ocaml package
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    uname -r | grep 'oe\|an' 
    if [ $? -eq 0 ]; then  
        DNF_INSTALL ocaml 
    else 
        APT_INSTALL ocaml 
    fi
    cp ../example.ml ../not.ml ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamlopt.opt -afl-instrument -afl-inst-ratio 63 example.ml
    CHECK_RESULT $?
    strings a.out | grep -E "afl|63"
    CHECK_RESULT $?
    ocamlopt.opt -S -inline 0 -nodynlink not.ml -o not.opt
    CHECK_RESULT $?
    grep "L110" not.s
    CHECK_RESULT $?
    ocamlopt.opt -inline-branch-factor 0.10 -inline-lifting-benefit 1300 -inline-alloc-cost 1 -inline-branch-cost 5 -inlining-report example.ml
    CHECK_RESULT $?
    grep -aE "inline" a.out
    CHECK_RESULT $?
    ./a.out | grep 6
    CHECK_RESULT $?
    ocamlopt.opt -clambda-checks example.ml
    CHECK_RESULT $?
    grep -aE "check.caml" a.out
    CHECK_RESULT $?
    ocamlopt.opt -Oclassic example.ml
    CHECK_RESULT $?
    grep -aE "caml_classify" a.out
    CHECK_RESULT $?
    ocamlopt.opt -v | grep -E "version|Standard library directory"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    APT_REMOVE
    rm -rf a.out ./example* ./not*
    LOG_INFO "End to restore the test environment."
}

main "$@"
