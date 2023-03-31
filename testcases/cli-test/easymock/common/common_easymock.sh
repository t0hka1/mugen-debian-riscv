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
# @Author    :   tangxiaolan
# @Contact   :   tangxiaolan0712@163.com
# @Date      :   2020/5/14
# @License   :   Mulan PSL v2
# @Desc      :   Public class integration
#####################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function deploy_env() {
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL "easymock junit" 
    else 
        APT_INSTALL "libeasymock-java junit" 
    fi
    java_version=$(rpm -qa java* | grep "java-.*-openjdk" | awk -F '-' '{print $2}')
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL java-${java_version}-devel 
    else 
        APT_INSTALL java-${java_version}-devel 
    fi
}

function clear_env() {
    APT_REMOVE
    rm -rf $(ls | grep -vE ".sh|.java|.xml|expect_result|main|test")
}

function compile_java() {
    params=$(basename -a ./*java)
    javac -classpath /usr/share/java/*:/usr/share/java/hamcrest/*: -d . $params

}

function execute_java() {
    testname=$(basename ./*Test*)
    java -classpath /usr/share/java/*:/usr/share/java/hamcrest/*: org.junit.runner.JUnitCore ${testname%.*}
}
