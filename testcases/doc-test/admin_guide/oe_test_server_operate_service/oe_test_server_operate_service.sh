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
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020-4-9
# @License   :   Mulan PSL v2
# @Desc      :   Verify service status
# #############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
	LOG_INFO "Start executing testcase."
	cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL nginx 
    else 
        APT_INSTALL nginx 
    fi
	LOG_INFO "End of testcase execution."
}

function run_test() {
	LOG_INFO "Start executing testcase."
	systemctl enable nginx
	systemctl is-enabled nginx | grep enable
	CHECK_RESULT $?
	systemctl start nginx
	systemctl status nginx | grep running
	CHECK_RESULT $?

	systemctl restart nginx
	systemctl status nginx | grep running
	CHECK_RESULT $?
	systemctl reload nginx
	CHECK_RESULT $?

	systemctl stop nginx
	systemctl status nginx | grep dead
	CHECK_RESULT $?
	systemctl disable nginx
	systemctl status nginx | grep disable
	CHECK_RESULT $?
	LOG_INFO "End of testcase execution."
}

function post_test() {
	LOG_INFO "start environment cleanup."
	APT_REMOVE
	LOG_INFO "Finish environment cleanup."
}

main $@
