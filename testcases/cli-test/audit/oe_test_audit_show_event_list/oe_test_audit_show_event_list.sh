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
#@Date      	:   2021-04-16 11:39:43
#@License   	:   Mulan PSL v2
#@Version   	:   1.0
#@Desc      	:   show event list
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start environmental preparation."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -ne 0 ]; then  
        APT_INSTALL auditd
    fi
    LOG_INFO "End of environmental preparation!"
}


function run_test()
{
    LOG_INFO "Start to run test."
    service auditd restart
    aureport -e -ts today -te today
    CHECK_RESULT $? 0 0 "aureport failed"
    LOG_INFO "End to run test."
}
main "$@"
