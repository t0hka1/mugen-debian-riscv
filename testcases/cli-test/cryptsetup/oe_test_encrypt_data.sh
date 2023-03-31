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
# @Author    :   huyahui
# @Contact   :   huyahui8@163.com
# @Date      :   2020/04/22
# @License   :   Mulan PSL v2
# @Desc      :   Encrypt data on unencrypted devices
# #############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function config_params() {
    LOG_INFO "Start loading data!"
    TEST_DISK="/dev/$(TEST_DISK 1)"
    LOG_INFO "Loading data is complete!"
}

function pre_test() {
    LOG_INFO "Start environmental preparation."
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL cryptsetup-reencrypt 
    else 
        APT_INSTALL cryptsetup
    fi
    echo -e "n\n\np\n\n\n+100M\nw" | fdisk "${TEST_DISK}"
    test -d /mnt/test_encrypted && rm -rf /mnt/test_encrypted
    mkdir /mnt/test_encrypted
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    echo -e "\n\n" | cryptsetup-reencrypt --new --reduce-device-size 8M "${TEST_DISK}"1
    CHECK_RESULT $? 0 0 "Disk encryption failed"
    echo -e "\n" | cryptsetup open "${TEST_DISK}"1 test_encrypted
    CHECK_RESULT $? 0 0 "Disk mapping failed"
    mkfs.ext4 /dev/mapper/test_encrypted -F
    CHECK_RESULT $? 0 0 "Failed to format partition"
    mount /dev/mapper/test_encrypted /mnt/test_encrypted
    CHECK_RESULT $? 0 0 "Disk mount failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    umount /mnt/test_encrypted
    cryptsetup close test_encrypted
    rm -rf /mnt/test_encrypted
    mkfs.ext4 ${TEST_DISK}1 -F
    echo -e "d\n\nw"| fdisk "${TEST_DISK}"
    APT_REMOVE
    mkfs.ext4 ${TEST_DISK} -F
    LOG_INFO "Finish environment cleanup!"
}
main "$@"
