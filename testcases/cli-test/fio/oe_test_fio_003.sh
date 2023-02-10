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
# @Date      :   2020-04-09
# @License   :   Mulan PSL v2
# @Desc      :   fio command test
# ############################################
source ./common/disk_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment!"
    check_free_disk
    uname -r | grep 'oe\|an' 
    if [ $? -eq 0 ]; then  
        DNF_INSTALL fio 
    else 
        APT_INSTALL fio 
    fi
    echo "dsafdsfdddddddddddddddddddddddddddddddddddddddddd" >test.txt
    LOG_INFO "End to prepare the test environment!"
}

function run_test() {
    LOG_INFO "Start executing testcase!"
    fio-dedupe -o 1 /dev/${local_disk} | grep "Will check </dev/${local_disk}>"
    CHECK_RESULT $? 0 0 "check disk failed"
    fio-dedupe -c 1 /dev/${local_disk} | grep "Will check </dev/${local_disk}>"
    CHECK_RESULT $? 0 0 "check disk failed"
    fio-dedupe -B 1 /dev/${local_disk} | grep "Will check </dev/${local_disk}>"
    CHECK_RESULT $? 0 0 "check disk failed"
    fio-dedupe -p 1 /dev/${local_disk} | grep "Will check </dev/${local_disk}>"
    CHECK_RESULT $? 0 0 "check disk failed"
    fio --filename=test_file --direct=1 --rw=randwrite --numjobs=1 --iodepth=16 --ioengine=libaio --bs=4k --group_reporting --name=zhangyi --log_avg_msec=500 --write_bw_log=test-fio --size=1G | grep "Starting 1 process"
    CHECK_RESULT $? 0 0 "fio --filename=test_file option failed"
    fio -filename=/dev/${local_disk} -direct=1 -iodepth 1 -thread -rw=read -ioengine=psync -bs=16k -size=200G -numjobs=30 -runtime=1000 -group_reporting -name=mytest | grep ${local_disk}
    CHECK_RESULT $? 0 0 "fio --filename=test_file option failed"
    fio -filename=/dev/${local_disk} -direct=1 -iodepth 1 -thread -rw=write -ioengine=psync -bs=16k -size=200G -numjobs=30 -runtime=1000 -group_reporting -name=mytest | grep ${local_disk}
    CHECK_RESULT $? 0 0 "fio --filename=test_file option failed"
    fio -filename=/dev/${local_disk} -direct=1 -iodepth 1 -thread -rw=randread -ioengine=psync -bs=16k -size=200G -numjobs=30 -runtime=1000 -group_reporting -name=mytest | grep ${local_disk}
    CHECK_RESULT $? 0 0 "fio --filename=test_file option failed"
    fio -filename=/dev/${local_disk} -direct=1 -iodepth 1 -thread -rw=randwrite -ioengine=psync -bs=16k -size=200G -numjobs=30 -runtime=1000 -group_reporting -name=mytest | grep ${local_disk}
    CHECK_RESULT $? 0 0 "fio --filename=test_file option failed"
    fio -filename=/dev/${local_disk} -direct=1 -iodepth 1 -thread -rw=read -ioengine=psync -bs=16k -size=200G -numjobs=30 -runtime=1000 -group_reporting -name=mytest --output test.txt
    test -f ./test_file
    CHECK_RESULT $? 0 0 "fio --filename=test_file option failed"
    genfio -d /dev/${local_disk},/dev/${local_disk1},/dev/${local_disk2} -a -b 4k,128k,1m -r 100 -a -x dellr720-day2/
    test -d dellr720-day2    
    CHECK_RESULT $? 0 0 "fio --filename=test_file option failed"
    LOG_INFO "End of testcase execution!"
}

function post_test() {
    LOG_INFO "Start environment cleanup."
    rm -rf test_file test.txt test-fio_bw.1.log dellr720-day2
    APT_REMOVE
    LOG_INFO "Finish environment cleanup."
}

main $@
