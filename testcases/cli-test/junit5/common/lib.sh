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
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Date      :   2020/5/14
# @License   :   Mulan PSL v2
# @Desc      :   Public class, environment construction
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function pre_junit5() {
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL junit5 
    else 
        APT_INSTALL junit5 
    fi
    java_version=$(rpm -qa 'java*' | grep 'java-.*-openjdk' | head -1 | awk -F - '{print $2}')
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL java-"${java_version}"-devel 
    else 
        APT_INSTALL java-"${java_version}"-devel 
    fi
}

function pre_maven() {
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL maven 
    else 
        APT_INSTALL maven 
    fi
    JAVA_HOME=/usr/lib/jvm/java-openjdk
    PATH=$PATH:$JAVA_HOME/bin
    export JAVA_HOME PATH
    export MAVEN_HOME=/usr/share/maven
    export PATH=$PATH:$MAVEN_HOME
}

function clean_maven() {
    APT_REMOVE
    source /etc/profile >/dev/null
}
