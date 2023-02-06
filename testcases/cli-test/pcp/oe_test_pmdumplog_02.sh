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
#@Author        :   zhujinlong
#@Contact       :   zhujinlong@163.com
#@Date          :   2020-10-14
#@License       :   Mulan PSL v2
#@Desc          :   pcp testing(pmdumplog)
#####################################

source "common/common_pcp.sh"

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    deploy_env
    archive_data=$(pcp -h "$host_name" | grep 'primary logger:' | awk -F: '{print $NF}')
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    pmdumplog -n /var/lib/pcp/pmns/root $archive_data | grep 'metrics'
    CHECK_RESULT $?
    pmdumplog -r $archive_data | grep 'metrics'
    CHECK_RESULT $?
    pmdumplog -S @00 -T @23 $archive_data | grep 'metrics'
    CHECK_RESULT $?
    pmdumplog -s $archive_data | grep 'metrics'
    CHECK_RESULT $?
    pmdumplog -t $archive_data | grep 'Log Vol'
    CHECK_RESULT $?
    pmdumplog -v ${archive_data}.index | grep 'index'
    CHECK_RESULT $?
    pmdumplog -x $archive_data | grep 'metrics'
    CHECK_RESULT $?
    pmdumplog -Z Asia/Shanghai $archive_data | grep 'timezone set'
    CHECK_RESULT $?
    pmdumplog -z $archive_data | grep 'local timezone'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    APT_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
