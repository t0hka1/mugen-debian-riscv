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
    pmdumplog --version 2>&1 | grep "$pcp_version"
    CHECK_RESULT $?
    pmdumplog -a $archive_data | grep 'Archive timezone'
    CHECK_RESULT $?
    pmdumplog -d $archive_data | grep 'PMID'
    CHECK_RESULT $?
    pmdumplog -e $archive_data | grep 'Metric Labels'
    CHECK_RESULT $?
    pmdumplog -h $archive_data | grep 'PMID'
    CHECK_RESULT $?
    pmdumplog -i $archive_data | grep 'Instance Domains'
    CHECK_RESULT $?
    pmdumplog -L $archive_data | grep 'Archive timezone'
    CHECK_RESULT $?
    pmdumplog -l $archive_data | grep 'Log Label'
    CHECK_RESULT $?
    pmdumplog -m $archive_data | grep 'metrics'
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    APT_REMOVE
    LOG_INFO "End to restore the test environment."
}

main "$@"
