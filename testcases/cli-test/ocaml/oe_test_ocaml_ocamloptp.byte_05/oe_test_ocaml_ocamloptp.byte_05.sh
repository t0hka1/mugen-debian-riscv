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
# @Date      :   2020/11/6
# @License   :   Mulan PSL v2
# @Desc      :   The usage of ocamloptp.byte under ocaml package
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
    cp /usr/lib64/ocaml/lazy.mli lazytest
    ocamloptp.byte -intf lazytest
    CHECK_RESULT $?
    grep -ai "lazytest" lazytest.cmi
    CHECK_RESULT $?
    cp /usr/lib64/ocaml/lazy.mli lazy.mli
    ocamloptp.byte -intf-suffix mli lazy.mli
    CHECK_RESULT $?
    grep -ai "lazy" lazy.cmi
    CHECK_RESULT $?
    ocamloptp.byte -keep-locs -alias-deps -app-funct -labels -linkall -keep-docs -safe-string -open Printf -principal -rectypes -strict-sequence -strict-formats -unboxed-types -unsafe -w +a-4-6-7-9-27-29-32..42-44-45-48-50-60 -warn-error -a+31 example.ml
    CHECK_RESULT $?
    ./a.out | grep 6 && rm -rf a.out
    CHECK_RESULT $?
    ocamloptp.byte -no-keep-locs -no-alias-deps -no-app-funct -nolabels -noassert -noautolink -no-keep-docs -no-principal -no-rectypes -no-strict-sequence -no-strict-formats -no-unboxed-types example.ml
    CHECK_RESULT $?
    grep -a "none" example.cmi
    CHECK_RESULT $?
    ocamloptp.byte -output-obj example.ml -o exampleobj.o
    CHECK_RESULT $?
    objdump -x exampleobj.o | grep "obj"
    CHECK_RESULT $?
    ocamloptp.byte -output-complete-obj example.ml -o examplecom.o
    CHECK_RESULT $?
    objdump -x examplecom.o | grep "obj_counter"
    CHECK_RESULT $?
    ocamloptp.byte -warn-help hello.ml | grep "warning"
    CHECK_RESULT $?
    ocamloptp.byte -verbose a.c 2>&1 | grep "gcc"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    APT_REMOVE
    rm -rf ./a* ./example* ./hello* ./lazy* ./lazytest* ocamlprof.dump
    LOG_INFO "End to restore the test environment."
}

main "$@"
