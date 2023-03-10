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
#@Date      	:   2020-07-02 09:00:43
#@License   	:   Mulan PSL v2
#@Desc      	:   verification ipvsadm‘s MOD command
####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    VIP=$(echo ${NODE1_IPV4} | cut -d '.' -f 1-3).100
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL ipvsadm 
    else 
        APT_INSTALL ipvsadm 
    fi
    ip addr add $VIP/22 dev ${NODE2_NIC}
    LOG_INFO "End to prepare the test environment."
}
function run_test() {
    LOG_INFO "Start to run test."
    ipvsadm
    CHECK_RESULT "$(ls /usr/sbin | grep -cE 'ipvsadm')" 3
    ipvsadm -C
    ipvsadm -A -t $VIP:80 -s rr
    ipvsadm -a -t $VIP:80 -r ${NODE2_IPV4}:80 -g
    ipvsadm -a -t $VIP:80 -r ${NODE3_IPV4}:80 -g
    CHECK_RESULT "$(ipvsadm -L | grep -cE 'Route')" 2
    CHECK_RESULT "$(ipvsadm -L | grep -cE 'rr')" 1
    SLEEP_WAIT 2
    ipvsadm -E -t $VIP:80 -s wrr
    ipvsadm -e -t $VIP:80 -r ${NODE2_IPV4}:80 -i
    ipvsadm -e -t $VIP:80 -r ${NODE3_IPV4}:80 -m
    CHECK_RESULT "$(ipvsadm -L | grep -cE 'wrr')" 1
    CHECK_RESULT "$(ipvsadm -L | grep -cE 'Masq')" 1
    CHECK_RESULT "$(ipvsadm -L | grep -cE 'Tunnel')" 1
    LOG_INFO "End to run test."
}
function post_test() {
    LOG_INFO "Start to restore the test environment."
    ipvsadm -C
    ip addr del $VIP/22 dev ${NODE2_NIC}
    APT_REMOVE
    LOG_INFO "End to restore the test environment."
}
main "$@"
