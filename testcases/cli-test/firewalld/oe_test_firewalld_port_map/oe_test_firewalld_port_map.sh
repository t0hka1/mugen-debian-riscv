#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Date      :   2022/04/22
# @License   :   Mulan PSL v2
# @Desc      :   Port Mapping
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL nmap 
    else 
        APT_INSTALL nmap 
    fi
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL nmap 2 
    else 
        APT_INSTALL nmap 2 
    fi
    sudo systemctl start firewalld
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    nc -l -p 5555 >/tmp/tmp_log 2>&1 &
    SSH_CMD "echo test | nc ${NODE1_IPV4} 6666" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $? 0 1
    sudo firewall-cmd --add-forward-port=port=6666:proto=tcp:toport=5555
    CHECK_RESULT $?
    sudo firewall-cmd --list-forward-ports | grep 6666 | grep 5555
    CHECK_RESULT $?
    SSH_CMD "echo test | nc ${NODE1_IPV4} 6666" "${NODE2_IPV4}" "${NODE2_PASSWORD}" "${NODE2_USER}"
    CHECK_RESULT $?
    grep test /tmp/tmp_log
    CHECK_RESULT $?
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sudo firewall-cmd --remove-forward-port=port=6666:proto=tcp:toport=5555
    rm -rf /tmp/tmp_log
    APT_REMOVE
    APT_REMOVE 2 nmap
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
