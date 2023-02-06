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
#@Desc      	:   verification ImageMagick‘s command
#####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    uname -r | grep 'oe\|an' 
    if [$? -eq 0]; then  
        DNF_INSTALL ImageMagick 
    else 
        APT_INSTALL ImageMagick 
    fi
    cp -r ../common ./tmp
    cd ./tmp
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    convert -monochrome test1.jpg bar3.jpg
    CHECK_RESULT $?
    test -f bar3.jpg
    CHECK_RESULT $?
    convert -paint 4 test1.jpg bar4.jpg
    CHECK_RESULT $?
    test -f bar4.jpg
    CHECK_RESULT $?
    convert -charcoal 2 test2.jpg bar5.jpg
    CHECK_RESULT $?
    test -f bar5.jpg
    CHECK_RESULT $?
    convert -spread 30 test2.jpg bar6.jpg
    CHECK_RESULT $?
    test -f bar6.jpg
    CHECK_RESULT $?
    convert -swirl 67 test2.jpg bar7.jpg
    CHECK_RESULT $?
    test -f bar7.jpg
    CHECK_RESULT $?
    convert -raise 5x5 test2.jpg bar8.jpg
    CHECK_RESULT $?
    test -f bar8.jpg
    CHECK_RESULT $?
    convert +raise 5x5 test2.jpg bar9.jpg
    CHECK_RESULT $?
    test -f bar9.jpg
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}
function post_test() {
    LOG_INFO "Start to restore the test environment."
    APT_REMOVE
    rm -rf ../tmp
    LOG_INFO "End to restore the test environment."
}
main "$@"
