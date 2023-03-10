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
# @Desc      :   Test mrtg.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL mrtg 
    else 
        APT_INSTALL mrtg 
    fi
    service=mrtg.service
    log_time=$(date '+%Y-%m-%d %T')
    echo "RunAsDaemon: yes
NoDetach: yes" >>/etc/mrtg/mrtg.cfg
    sed -i 's\mrtg.ok\mrtg.ok --daemon\g' /usr/lib/systemd/system/mrtg.service
    systemctl daemon-reload
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_restart "${service}"
    test_enabled "${service}"
    journalctl --since "${log_time}" -u "${service}" | grep -i "fail\|error" | grep -v -i "DEBUG\|INFO\|WARNING" | grep -v "ERROR: Bailout after SIG TERM"
    CHECK_RESULT $? 0 1 "There is an error message for the log of ${service}"
    test_reload "${service}"
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop "${service}"
    APT_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
