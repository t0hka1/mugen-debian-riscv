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
# @Desc      :   Test hadoop-resourcemanager.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL "hadoop-yarn java-1.8.0-openjdk hadoop-hdfs" 
    else 
        APT_INSTALL "hadoop-yarn java-1.8.0-openjdk hadoop-hdfs" 
    fi
    echo "export JAVA_HOME=/usr/lib/jvm/jre" >>/usr/libexec/hadoop-layout.sh
    sed -i "/Group=hadoop/a SuccessExitStatus=143" /usr/lib/systemd/system/hadoop-resourcemanager.service
    systemctl daemon-reload
    expect <<EOF
        spawn sudo -u hdfs hdfs namenode -format
        expect {
            "(Y or N)" {
                send "Y\r"
            }
        }
        expect eof
EOF
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start testing..."
    test_execution hadoop-resourcemanager.service
    test_reload hadoop-resourcemanager.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i "/export JAVA_HOME=\/usr\/lib\/jvm\/jre/d" /usr/libexec/hadoop-layout.sh
    sed -i "/SuccessExitStatus=143/d" /usr/lib/systemd/system/hadoop-resourcemanager.service
    systemctl daemon-reload
    APT_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
