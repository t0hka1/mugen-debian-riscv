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
# @Author    :   zhanglu626
# @Contact   :   m18409319968@163.com
# @Date      :   2022/01/18
# @License   :   Mulan PSL v2
# @Desc      :   A c++ SDK
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    uname -r | grep 'oe\|an' 
    if [$? -eq 0]; then  
        DNF_INSTALL libdap 
    else 
        APT_INSTALL libdap 
    fi
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    getdap -i "https://e.gitee.com/open_euler/dashboard?issue=I4BVTY" 2>&1 | grep 'DAP version:'
    CHECK_RESULT $? 0 0 "Failed to obtain the DAP version"
    getdap -d "https://e.gitee.com/open_euler/dashboard?issue=I4BVTY" 2>&1 | grep 'Dataset'
    CHECK_RESULT $? 0 0 "Failed to obtain the DDS"
    getdap -a "https://e.gitee.com/open_euler/dashboard?issue=I4BVTY" 2>&1 | grep 'Attributes'
    CHECK_RESULT $? 0 0 "Failed to obtain the DAS"
    getdap -x 'https://e.gitee.com/open_euler/dashboard?issue=I4BVTY' 2>&1 | grep 'DAP2'
    CHECK_RESULT $? 0 0 "Failed to obtain the DAP2"
    getdap -B "https://e.gitee.com/open_euler/dashboard?issue=I4BVTY" 2>&1 | grep 'DAP2'
    CHECK_RESULT $? 0 0 "Failed to get DAP2 without data"
    getdap -iv "https://e.gitee.com/open_euler/dashboard?issue=I4BVTY" 2>&1 | grep 'Server version'
    CHECK_RESULT $? 0 0 "Failed to obtain the Server version"
    getdap -V "https://e.gitee.com/open_euler/dashboard?issue=I4BVTY" 2>&1 | grep 'getdap version'
    CHECK_RESULT $? 0 0 "Failed to obtain the getdap version"
    ls -Rl /tmp >size1
    getdap -k 'https://e.gitee.com/open_euler/dashboard?issue=I4BVTY'
    ls -Rl /tmp >size2
    diff size1 size2 | grep "<"
    CHECK_RESULT $? 0 0 "Failed to save the temporary file created by libdap"
    getdap -m 3 "https://e.gitee.com/open_euler/dashboard?issue=I4BVTY" >aaa 2>&1
    A=$(grep -c "https://e.gitee.com/open_euler/dashboard?issue=I4BVTY" aaa)
    if [ "$(A)" == 3 ]; then
        echo "True"
    fi
    CHECK_RESULT $? 0 0 "Failed to request the same URL 3 times"
    getdap -z 'https://e.gitee.com/open_euler/dashboard?issue=I4BVTY'
    CHECK_RESULT $? 0 0 "Data compression failure"
    getdap -s 'https://e.gitee.com/open_euler/dashboard?issue=I4BVTY' 2>&1 | grep '193' | grep '242' | grep '326'
    CHECK_RESULT $? 0 0 "Failed to print sequence with numbered line"
    getdap -M 'https://e.gitee.com/open_euler/dashboard?issue=I4BVTY' 2>&1 | grep 'stylesheet'
    CHECK_RESULT $? 0 0 "Failed to read data from file without MIME header"
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    APT_REMOVE
    rm -rf aaa size*
    LOG_INFO "Finish environment cleanup."
}

main $@
