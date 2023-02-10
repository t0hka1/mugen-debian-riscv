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
# @Date      :   2020/10/28
# @License   :   Mulan PSL v2
# @Desc      :   The usage of ocamldoc.opt under ocaml package
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
    cp ../example.ml ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    ocamldoc.opt -html -all-params example.ml
    CHECK_RESULT $?
    grep "param" Example.html
    CHECK_RESULT $?
    ocamldoc.opt -html -css-style example.ml
    CHECK_RESULT $?
    grep "css" index.html
    CHECK_RESULT $?
    ocamldoc.opt -html -colorize-code example.ml
    CHECK_RESULT $?
    grep "code" Example.html
    CHECK_RESULT $?
    rm -rf Example.html type_Example.html
    ocamldoc.opt -html -index-only example.ml
    CHECK_RESULT $?
    ls ./index*
    CHECK_RESULT $?
    test -f Example.html -a -f type_Example.html
    CHECK_RESULT $? 0 1
    ocamldoc.opt -html -short-functors example.ml
    CHECK_RESULT $?
    grep "sig" Example.html | grep ":"
    CHECK_RESULT $?
    ocamldoc.opt -latex -latex-value-prefix valuepre example.ml
    CHECK_RESULT $?
    grep "valuepre" ocamldoc.out
    CHECK_RESULT $?
    ocamldoc.opt -latex -latextitle 0,section example.ml
    CHECK_RESULT $?
    grep "section" ocamldoc.out
    CHECK_RESULT $?
    ocamldoc.opt -latex -noheader example.ml
    CHECK_RESULT $?
    grep "usepackage" ocamldoc.out
    CHECK_RESULT $? 1
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    APT_REMOVE
    rm -rf ./*html example.ml ./ocamldoc* style.css
    LOG_INFO "End to restore the test environment."
}

main "$@"
