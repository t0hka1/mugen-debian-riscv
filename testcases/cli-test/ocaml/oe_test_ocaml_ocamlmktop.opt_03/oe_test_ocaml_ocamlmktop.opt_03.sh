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
# @Date      :   2020/11/4
# @License   :   Mulan PSL v2
# @Desc      :   The usage of ocamlmktop.opt under ocaml package
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
    cp ../a.c ../example.ml ../hello.ml ./
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    cp /usr/lib64/ocaml/lazy.mli lazy.mli
    ocamlmktop.opt -intf-suffix mli lazy.mli
    CHECK_RESULT $?
    grep -ai "lazy" lazy.cmi
    CHECK_RESULT $?
    ocamlmktop.opt -alias-deps example.ml
    CHECK_RESULT $?
    grep -ai "alias" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.opt -keep-locs example.ml
    CHECK_RESULT $?
    grep -ai "locs" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.opt -app-funct example.ml
    CHECK_RESULT $?
    grep -ai "app-funct" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.opt -labels example.ml
    CHECK_RESULT $?
    grep -ai "labels" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.opt -linkall example.ml
    CHECK_RESULT $?
    grep -ai "linkall" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.opt -keep-docs example.ml
    CHECK_RESULT $?
    grep -ai "docs" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.opt -safe-string example.ml
    CHECK_RESULT $?
    grep -ai "safe" a.out && rm -rf a.out
    CHECK_RESULT $?
    ocamlmktop.opt -open Printf example.ml
    CHECK_RESULT $?
    grep -a "Printf" a.out && rm -rf a.out
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    APT_REMOVE
    rm -rf ./a* ./example* ./hello* ./lazy*
    LOG_INFO "End to restore the test environment."
}

main "$@"
