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
# @Desc      :   Test sntp.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    uname -r | grep 'oe\|an' 
    if [ $? -eq 0 ]; then  
        DNF_INSTALL ntp 
    else 
        APT_INSTALL ntp 
    fi
    echo "server 127.127.1.0 iburst prefer maxpoll 4 minpoll 4" >> /etc/ntp.conf
    sed -i "s/restrict default nomodify notrap nopeer noepeer noquery/#restrict default nomodify notrap nopeer noepeer noquery/" \
/etc/ntp.conf
    sed -i 's/OPTIONS=/#OPTIONS=/' /etc/sysconfig/sntp
    echo 'OPTIONS="-s -d localhost"' >> /etc/sysconfig/sntp
    systemctl start ntpd.service
    SLEEP_WAIT 5
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution sntp.service
    test_reload sntp.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    systemctl stop sntp.service
    systemctl stop ntpd.service
    sed -i '/OPTIONS="-s -d localhost"/d' /etc/sysconfig/sntp
    sed -i 's/#OPTIONS=/OPTIONS=/' /etc/sysconfig/sntp
    sed -i "/server 127.127.1.0 iburst prefer maxpoll 4 minpoll 4/d" /etc/ntp.conf
    sed -i "s/#restrict default nomodify notrap nopeer noepeer noquery/restrict default nomodify notrap nopeer noepeer noquery/" \
/etc/ntp.conf
    APT_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
