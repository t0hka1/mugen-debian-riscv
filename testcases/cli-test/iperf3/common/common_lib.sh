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
#@Date          :   2020/10/10
#@License       :   Mulan PSL v2
#@Desc          :   iperf3 command line test public functions
####################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_env() {

    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL "iperf3" 
    else 
        APT_INSTALL "iperf3" 
    fi
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL "iperf3" 2 
    else 
        APT_INSTALL "iperf3" 2 
    fi
    P_SSH_CMD --cmd "systemctl stop firewalld
             iperf3 -s >/dev/null 2>&1 &
    "

}

function clean_env() {

    P_SSH_CMD --cmd "kill -9 \$(ps -ef | grep \\\"iperf3 -s\\\" | grep -v grep | awk '{print \$2}')
             systemctl start firewalld
             "
    APT_REMOVE

}
