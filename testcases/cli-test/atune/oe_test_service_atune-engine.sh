#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more detaitest -f.

# #############################################
# @Author    :   huangrong
# @Contact   :   1820463064@qq.com
# @Date      :   2020/10/23
# @License   :   Mulan PSL v2
# @Desc      :   Test atune-engine.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    uname -r | grep 'oe\|an' 
    if [ $? -eq 0 ]; then  
        DNF_INSTALL "atune-engine atune" 
    else 
        APT_INSTALL "atune-engine atune" 
    fi
    disk_name=$(lsblk | grep disk | awk 'NR==1{print $1}')
    sed -i "s\disk = sda\disk = ${disk_name}\g" /etc/atuned/atuned.cnf
    sed -i "s\network = enp189s0f0\network = ${NODE1_NIC}\g" /etc/atuned/atuned.cnf
    systemctl start atuned.service
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution atune-engine.service
    test_reload atune-engine.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop atuned.service
    sed -i "s\disk = ${disk_name}\disk = sda\g" /etc/atuned/atuned.cnf
    sed -i "s\network = ${NODE1_NIC}\network = enp189s0f0\g" /etc/atuned/atuned.cnf
    APT_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"

