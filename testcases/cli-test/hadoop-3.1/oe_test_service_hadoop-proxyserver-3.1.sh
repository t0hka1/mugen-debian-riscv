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
# @Desc      :   Test hadoop-proxyserver.service restart
# #############################################

source "../common/common_lib.sh"

function pre_test() {
    LOG_INFO "Start environmental preparation."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL "hadoop-3.1-yarn java-1.8.0-openjdk hadoop-3.1-hdfs" 
    else 
        APT_INSTALL "hadoop-3.1-yarn java-1.8.0-openjdk hadoop-3.1-hdfs" 
    fi
    echo "export JAVA_HOME=/usr/lib/jvm/jre" >>/usr/libexec/hadoop-layout.sh
    sed -i "/Group=hadoop/a SuccessExitStatus=143" /usr/lib/systemd/system/hadoop-proxyserver.service
    systemctl daemon-reload
    cp -raf /etc/hadoop/yarn-site.xml /tmp
    sed -i "/<value>mapreduce_shuffle<\/value>/a<\/property>\n<property>\n<name>yarn.web-proxy.address<\/name>\n<value>${NODE1_IPV4}<\/value>" /etc/hadoop/yarn-site.xml
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
    test_execution hadoop-proxyserver.service
    test_reload hadoop-proxyserver.service
    LOG_INFO "Finish test!"
}

function post_test() {
    LOG_INFO "start environment cleanup."
    sed -i "/export JAVA_HOME=\/usr\/lib\/jvm\/jre/d" /usr/libexec/hadoop-layout.sh
    sed -i "/SuccessExitStatus=143/d" /usr/lib/systemd/system/hadoop-proxyserver.service
    systemctl daemon-reload
    mv /tmp/yarn-site.xml /etc/hadoop/yarn-site.xml
    APT_REMOVE
    LOG_INFO "Finish environment cleanup!"
}

main "$@"
