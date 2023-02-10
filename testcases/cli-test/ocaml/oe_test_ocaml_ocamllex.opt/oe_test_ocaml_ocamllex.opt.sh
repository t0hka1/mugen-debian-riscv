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
# @Date      :   2020/10/21
# @License   :   Mulan PSL v2
# @Desc      :   The usage of ocamllex, ocamlobjinfo and other commands in ocaml package
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
    cp ../sourcefile ./
    ocaml_version=$(rpm -qa ocaml | awk -F '-' '{print $2}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamllex.opt -ml sourcefile
    CHECK_RESULT $?
    grep "ocaml_lex" sourcefile.ml
    CHECK_RESULT $?
    ocamllex.opt sourcefile -o outfile1 | grep "size"
    CHECK_RESULT $?
    grep "sourcefile" outfile1
    CHECK_RESULT $?
    ocamllex.opt -q sourcefile -o outfile2 >log
    CHECK_RESULT $?
    test -s log
    CHECK_RESULT $? 0 1
    ocamllex.opt -v sourcefile | grep -E "OCaml lexer|$ocaml_version"
    CHECK_RESULT $?
    ocamllex.opt -vnum sourcefile | grep "$ocaml_version"
    CHECK_RESULT $?
    ocamllex.opt -help | grep "ocamllex"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    APT_REMOVE
    rm -rf ./outfile* ./sourcefile* log
    LOG_INFO "End to restore the test environment."
}

main "$@"
