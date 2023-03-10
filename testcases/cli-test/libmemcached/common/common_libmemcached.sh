#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# ############################################
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/27
# @License   :   Mulan PSL v2
# @Version   :   1.0
# @Desc      :   public class integration
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function deploy_env() {
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL "libmemcached memcached telnet net-tools" 
    else 
        APT_INSTALL "libmemcached memcached telnet net-tools" 
    fi
    memcached -d -u root -m 512 -p 11211
    SLEEP_WAIT 5
    netstat -an | grep 11211
    pgrep -f 'memcached -d -u'
}

function clear_env() {
    kill -9 $(pgrep -f 'memcached -d -u')
    rm -rf $(ls | grep -vE ".sh|config")
    APT_REMOVE
}
