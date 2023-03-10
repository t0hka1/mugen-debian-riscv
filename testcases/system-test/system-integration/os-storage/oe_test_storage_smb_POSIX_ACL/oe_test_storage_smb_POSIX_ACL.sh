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
# @Date      :   2020-4-10
# @License   :   Mulan PSL v2
# @Desc      :   SMB add share using POSIX ACL
# #############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start environment preparation."
    SSH_CMD "yum install -y samba; sed -i '/testsamba/d' /etc/security/opasswd;useradd testsamba;
    (echo ${NODE1_PASSWORD};echo ${NODE1_PASSWORD}) | smbpasswd -a testsamba -s" \
        ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "test -d /tmp/testsamba || mkdir -p /tmp/testsamba; if [ $(getenforce) = 'SELinux'];then semanage fcontext -a -t samba_share_t \"/tmp/testsamba/(/.*)?\";restorecon -Rv /tmp/testsamba/;fi" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "cp -a /etc/samba/smb.conf /etc/samba/smb.conf.bak;echo  \\\" \\\" >> /etc/samba/smb.conf;
    echo  \\\"\\[example\\]\\\" >> /etc/samba/smb.conf;echo  \\\"\\tpath = /tmp/testsamba\\\" >> /etc/samba/smb.conf;
    echo  \\\"\\tread only = no\\\" >> /etc/samba/smb.conf" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    SSH_CMD "systemctl stop firewalld; systemctl restart smb || systemctl start smb;systemctl enable smb;
    setsebool -P samba_export_all_ro on;setsebool -P samba_export_all_rw on" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL cifs-utils 
    else 
        APT_INSTALL cifs-utils 
    fi
    systemctl stop firewalld
    mkdir -p /home/client
    LOG_INFO "Environmental preparation is over."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    mount -t cifs -o username=testsamba,password=${NODE1_PASSWORD} //${NODE2_IPV4}/testsamba /home/client
    CHECK_RESULT $?
    df -h | grep -i '/home/client' | grep "${NODE2_IPV4}"
    CHECK_RESULT $?
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    umount /home/client
    rmdir /home/client
    SSH_CMD "systemctl stop smb; rm -f /etc/samba/smb.conf;mv /etc/samba/smb.conf.bak /etc/samba/smb.conf;
    yum remove samba -y; userdel -r testsamba; rm -rf /tmp/testsamba; systemctl start firewalld" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    APT_REMOVE
    systemctl start firewalld
    LOG_INFO "Finish environment cleanup."
}

main $@
