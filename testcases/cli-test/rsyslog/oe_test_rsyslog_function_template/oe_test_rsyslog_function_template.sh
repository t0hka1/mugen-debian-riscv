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
# @Author    :   wangshan
# @Contact   :   wangshan@163.com
# @Date      :   2020-08-03
# @License   :   Mulan PSL v2
# @Desc      :   Use templates to filter logs
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."
    uname -r | grep 'oe\|an' 
    if [$? -eq 0]; then  
        DNF_INSTALL rsyslog 
    else 
        APT_INSTALL rsyslog 
    fi
    cat >/etc/rsyslog.d/test.conf <<EOF
    \$EscapeControlCharactersOnReceive off 
    \$template test-template,"%timestamp:::date-rfc3339%  %HOSTNAME% %msgid% %msg%\n"
    local5.* /var/log/test;test-template
EOF
    systemctl restart rsyslog
    CHECK_RESULT $?
    time=$(date +%s%N | cut -c 9-13)
    logger -t local5 -p local5.info "test$time"
    CHECK_RESULT $?
    date=$(date -d today +"%Y-%m-%d")
    SLEEP_WAIT 10
    grep $date /var/log/test | grep "test$time"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /var/log/test /etc/rsyslog.d/test.conf
    systemctl restart rsyslog
    LOG_INFO "End to restore the test environment."
}
main "$@"
