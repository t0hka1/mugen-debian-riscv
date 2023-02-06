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
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Date      :   2020/5/14
# @License   :   Mulan PSL v2
# @Desc      :   Abnormal test, delete necessary jar
# #############################################

source "../common/lib.sh"

function pre_test() {
    LOG_INFO "Start environment preparation."
    pre_junit5
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    javac -cp ../common/junit-platform-console-standalone-1.6.2.jar -d . TestJunit5.java
    CHECK_RESULT $?
    java -jar ../common/junit-platform-console-standalone-1.6.2.jar -cp ./ --class-path . --scan-class-path
    CHECK_RESULT $?
    rm -rf com
    javac -cp -d . TestJunit5.java
    CHECK_RESULT $? 0 1
    java -jar -cp ./ --class-path . --scan-class-path
    CHECK_RESULT $? 0 1
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    APT_REMOVE
    rm -rf com
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
