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
# @Author    :   zengcongwei
# @Contact   :   735811396@qq.com
# @Date      :   2020/12/29
# @License   :   Mulan PSL v2
# @Desc      :   Test rsyncd.socket restart 
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    uname -r | grep 'oe\|an' 
    if [$? -eq 0]; then  
        DNF_INSTALL rsync 
    else 
        APT_INSTALL rsync 
    fi
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start to run test."
    test_execution rsyncd.socket
    test_reload rsyncd.socket
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systtemctl stop rsyncd.socket
    APT_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
