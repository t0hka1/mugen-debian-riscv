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
#@Date          :   2020-07-02 11:00:43
#@License   	:   Mulan PSL v2
#@Desc          :   verification ipvsadm‘s DR_rr model
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    VIP=$(echo ${NODE1_IPV4} | cut -d '.' -f 1-3).100
    uname -r | grep 'oe\|an' 
    if [ $? -eq 0 ]; then  
        DNF_INSTALL "ipvsadm httpd" 
    else 
        APT_INSTALL "ipvsadm httpd" 
    fi
    systemctl start httpd
    systemctl stop firewalld
    ip addr add $VIP/22 dev ${NODE2_NIC}
    ipvsadm
    ipvsadm -C
    ipvsadm -A -t $VIP:80 -s rr
    ipvsadm -a -t $VIP:80 -r ${NODE2_IPV4}:80 -g
    ipvsadm -a -t $VIP:80 -r ${NODE3_IPV4}:80 -g
    SLEEP_WAIT 10
    ipvsadm-save >/etc/sysconfig/ipvsadm
    SLEEP_WAIT 10
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    SSH_SCP ../common/LVS_DR_RIP_config.sh ${NODE2_USER}@${NODE2_IPV4}:/tmp/LVS_DR_RIP_config.sh ${NODE2_PASSWORD}
    SSH_CMD "bash -x /tmp/LVS_DR_RIP_config.sh start" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_SCP ../common/LVS_DR_RIP_config.sh ${NODE3_USER}@${NODE3_IPV4}:/tmp/LVS_DR_RIP_config.sh ${NODE3_PASSWORD}
    SSH_CMD "bash -x /tmp/LVS_DR_RIP_config.sh start" ${NODE3_IPV4} ${NODE3_PASSWORD} ${NODE3_USER}
    SSH_SCP ../common/GET_CURL_RESULT.sh ${NODE4_USER}@${NODE4_IPV4}:/tmp/GET_CURL_RESULT.sh ${NODE4_PASSWORD}
    SSH_CMD "bash -x /tmp/GET_CURL_RESULT.sh" ${NODE4_IPV4} ${NODE4_PASSWORD} ${NODE4_USER}
    SSH_SCP ${NODE4_USER}@${NODE4_IPV4}:/tmp/result_curl.txt ./result_curl.txt ${NODE4_PASSWORD}
    CHECK_RESULT "$(grep -cE "${NODE2_IPV4}" ./result_curl.txt)" 3
    CHECK_RESULT "$(grep -cE "${NODE3_IPV4}" ./result_curl.txt)" 3
    SLEEP_WAIT 2
    SSH_CMD "systemctl start firewalld" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SLEEP_WAIT 2
    SSH_CMD "rm -rf /tmp/result_curl.txt && bash -x /tmp/GET_CURL_RESULT.sh" ${NODE4_IPV4} ${NODE4_PASSWORD} ${NODE4_USER}
    SSH_SCP ${NODE4_USER}@${NODE4_IPV4}:/tmp/result_curl.txt ./result_curl1.txt ${NODE4_PASSWORD}
    CHECK_RESULT "$(grep -cE "${NODE2_IPV4}" ./result_curl1.txt)" 0
    CHECK_RESULT "$(grep -cE "${NODE3_IPV4}" ./result_curl1.txt)" 3
    SLEEP_WAIT 2
    SSH_CMD "systemctl start firewalld" ${NODE3_IPV4} ${NODE3_PASSWORD} ${NODE3_USER}
    SLEEP_WAIT 2
    SSH_CMD "rm -rf /tmp/result_curl.txt && bash -x /tmp/GET_CURL_RESULT.sh" ${NODE4_IPV4} ${NODE4_PASSWORD} ${NODE4_USER}
    SSH_SCP ${NODE4_USER}@${NODE4_IPV4}:/tmp/result_curl.txt ./result_curl2.txt ${NODE4_PASSWORD}
    CHECK_RESULT "$(grep -cE "${NODE2_IPV4}" ./result_curl2.txt)" 0
    CHECK_RESULT "$(grep -cE "${NODE3_IPV4}" ./result_curl2.txt)" 0
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    systemctl start firewalld
    systemctl stop httpd
    ipvsadm -C
    rm -rf /etc/sysconfig/ipvsadm ./result_*
    ip addr del $VIP/22 dev ${NODE2_NIC}
    APT_REMOVE
    SSH_CMD "bash -x /tmp/LVS_DR_RIP_config.sh stop" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "bash -x /tmp/LVS_DR_RIP_config.sh stop" ${NODE3_IPV4} ${NODE3_PASSWORD} ${NODE3_USER}
    SSH_CMD "rm -rf /tmp/GET_CURL_RESULT.sh /tmp/result_curl.txt" ${NODE4_IPV4} ${NODE4_PASSWORD} ${NODE4_USER}
    LOG_INFO "End to restore the test environment."
}
main "$@"
