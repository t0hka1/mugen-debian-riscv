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
#@Author    	:   Jevons
#@Contact   	:   1557927445@qq.com
#@Date      	:   2021-05-31 09:39:43
#@License   	:   Mulan PSL v2
#@Version   	:   1.0
#@Desc      	:   set max log file keep logs
#####################################

source ../common/comlib.sh

function pre_test(){
    LOG_INFO "Start to prepare the test environment."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -ne 0 ]; then  
        APT_INSTALL auditd
    fi
    sed -i 's/max_log_file = 8/max_log_file = 1/g' "/etc/audit/auditd.conf"
    sed -i 's/num_logs = 5/num_logs = 2/g' "/etc/audit/auditd.conf"
    sed -i 's/max_log_file_action = ROTATE/max_log_file_action = KEEP_LOGS/g' "/etc/audit/auditd.conf"
    service auditd restart
    LOG_INFO "End to prepare the environment"
}
function run_test()
{
    LOG_INFO "Start to run test."
    for ((i=0;i<10;i++));do
        old_size=$(du -ks /var/log/audit/ | awk '{print $1}')
        old_num=$(find /var/log/audit -maxdepth 1 -name "audit.log*" | wc -l)
        old=$(ls -i /var/log/audit/audit.log* | tail -n 1 | awk '{print $1}')
        create_logfile
        new=$(ls -i /var/log/audit/audit.log* | tail -n 1 | awk '{print $1}')
        new_size=$(du -ks /var/log/audit/ | awk '{print $1}')
        new_num=$(find /var/log/audit -maxdepth 1 -name "audit.log*" | wc -l)
        test $(("$new_size" - "$old_size")) -gt 1024 &&{
        if [[ "$old" != "$new" && "$old_size" -lt "$new_size" && "$old_num" -le "$new_num" ]]; then
            break
        else
            test "$i" -eq 9 &&{
                CHECK_RESULT 1 0 0 "keep_logs error"
            }
        fi		
        }
    done
    LOG_INFO "End to run test."
}

function post_test()
{
    LOG_INFO "Start to restore the test environment."
    sed -i 's/max_log_file = 1/max_log_file = 8/g' "/etc/audit/auditd.conf"
    sed -i 's/num_logs = 2/num_logs = 5/g' "/etc/audit/auditd.conf"
    sed -i 's/max_log_file_action = KEEP_LOGS/max_log_file_action = ROTATE/g' "/etc/audit/auditd.conf"
    service auditd restart
    LOG_INFO "End to restore the test environment."
}

main "$@"
