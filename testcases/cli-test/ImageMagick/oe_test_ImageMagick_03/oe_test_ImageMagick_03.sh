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
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL ImageMagick 
    else 
        APT_INSTALL imagemagick 
    fi
    cp -r ../common ./tmp
    cd ./tmp
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    convert test1.jpg -region 127x650+1070+150 -resize 120% -fill "#eae4ba" -colorize 100% result.jpg
    CHECK_RESULT $?
    test -f result.jpg
    CHECK_RESULT $?
    convert -rotate 270 test3.jpg test3-final.jpg
    CHECK_RESULT $?
    test -f test3-final.jpg
    CHECK_RESULT $?
    FONT=$(convert -list font|grep -i "Font:"| awk -F ':' '{print $2}' | head -1)
    convert -fill black -pointsize 60 -font $FONT -draw 'text 100,800 "hello"' test3.jpg hello.jpg
    CHECK_RESULT $?
    test -f hello.jpg
    CHECK_RESULT $?
    convert -flip test1.jpg bar.jpg
    CHECK_RESULT $?
    test -f bar.jpg
    CHECK_RESULT $?
    convert -flop test1.jpg bar1.jpg
    CHECK_RESULT $?
    test -f bar1.jpg
    CHECK_RESULT $?
    convert -negate test1.jpg bar2.jpg
    CHECK_RESULT $?
    test -f bar2.jpg
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
