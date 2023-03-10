#!/usr/bin/bash

# Copyright (c) 2022 Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   duanxuemin
# @Contact   :   duanxuemin_job@163.com
# @Date      :   2022-04-09
# @License   :   Mulan PSL v2
# @Desc      :   lvm2 command test
# ############################################
source ./common/disk_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    cat /etc/os-release | grep -i 'openeuler\|anolis'
    if [ $? -eq 0 ]; then  
        DNF_INSTALL lvm2 
    else 
        APT_INSTALL lvm2 
    fi
    check_free_disk
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    pvcreate -y /dev/${local_disk}
    CHECK_RESULT $? 0 0 "create PV failed"
    pvs | grep "/dev/${local_disk}"
    CHECK_RESULT $? 0 0 "create PV failed"
    vgcreate test /dev/${local_disk}
    CHECK_RESULT $? 0 0 "create VG failed"
    vgdisplay | grep "VG Name" | grep "test"
    CHECK_RESULT $? 0 0 "create VG failed"
    vgchange --longhelp | grep "Change volume group attributes"
    CHECK_RESULT $? 0 0 "vgchange --longhelp failed"
    vgchange --help | grep "Change volume group attributes"
    CHECK_RESULT $? 0 0 "vgchange --help failed"
    vgchange --version | grep "LVM version"
    CHECK_RESULT $? 0 0 "failed to test vgchange --version"
    vgchange --poll y --ignorelockingfailure test
    CHECK_RESULT $? 0 0 "failed to test vgchange --poll y"
    vgchange --refresh --autobackup y test
    CHECK_RESULT $? 0 0 "failed to test vgchange --refresh --autobackup y"
    vgchange --refresh --sysinit test
    CHECK_RESULT $? 0 0 "failed to test vgchange --refresh --sysinit"
    vgchange --refresh --reportformat basic test
    CHECK_RESULT $? 0 0 "failed to test vgchange --refresh --reportformat basic"
    vgchange --refresh --reportformat json test
    CHECK_RESULT $? 0 0 "vgchange --refresh --reportformat json"
    LOG_INFO "End executing testcase!"
}
function post_test() {
    LOG_INFO "Start environment cleanup."
    vgremove -f test
    pvremove -f /dev/${local_disk}
    APT_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
