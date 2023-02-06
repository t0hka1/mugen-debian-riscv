#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
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
# @Desc      :   Test systemd-journal-upload.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    uname -r | grep 'oe\|an' 
    if [$? -eq 0]; then  
        DNF_INSTALL systemd-journal-remote 
    else 
        APT_INSTALL systemd-journal-remote 
    fi
    if [ $(getenforce | grep Enforcing) ]; then
        setenforce 0
        flag=true
    fi
    sed -i "s\# URL=\URL=http://${NODE1_IPV4}:19532\g" /etc/systemd/journal-upload.conf
    sed -i "s\listen-https=-3\listen-http=-3\g" /usr/lib/systemd/system/systemd-journal-remote.service
    systemctl daemon-reload
    systemctl restart systemd-journal-remote.service
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution systemd-journal-upload.service
    test_reload systemd-journal-upload.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    sed -i "s\URL=http://${NODE1_IPV4}:19532\# URL=\g" /etc/systemd/journal-upload.conf
    sed -i "s\listen-http=-3\listen-https=-3\g" /usr/lib/systemd/system/systemd-journal-remote.service
    systemctl daemon-reload
    systemctl stop systemd-journal-remote.service
    systemctl stop systemd-journal-upload.service
    APT_REMOVE
    if [ ${flag} = 'true' ]; then
        setenforce 1
    fi
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
