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
#@Author        :   wangjingfeng
#@Contact       :   1136232498@qq.com
#@Date          :   2020/4/29
#@License       :   Mulan PSL v2
#@Desc          :   testNG integration Junit
####################################
source ../common/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."

    pre_env
    uname -r | grep 'oe\|an' 
    if [$? -eq 0]; then  
        DNF_INSTALL "junit hamcrest" 
    else 
        APT_INSTALL "junit hamcrest" 
    fi
    junit_jar=$(rpm -ql junit | grep junit.jar)
    hamcrestcore_jar=$(rpm -ql hamcrest | grep core.jar)
    export CLASSPATH=${CLASSPATH}:${junit_jar}:${hamcrestcore_jar}

    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."

    javac JunitTestNG.java
    CHECK_RESULT $? 0 0 "java source code compilation failed."
    java -cp "${CLASSPATH}" org.testng.TestNG testng_junit.xml | grep "run: 1, Failures: 0, Skips: 0"
    CHECK_RESULT $? 0 0 "testng execution use case failed."

    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."

    clean_env

    LOG_INFO "End to restore the test environment."
}

main "$@"
