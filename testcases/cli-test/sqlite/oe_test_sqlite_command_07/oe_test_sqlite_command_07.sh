#!/usr/bin/bash
# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   guochenyang
#@Contact   	:   377012421@qq.com
#@Date      	:   2020-07-02 09:00:43
#@License   	:   Mulan PSL v2
#@Desc      	:   verification sqlite‘s .backup and .restore  command
#####################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
    LOG_INFO "Start to run test."
    expect <<-END
    spawn sqlite3 ./test.db
    send "CREATE TABLE COMPANY(
          ID INT PRIMARY KEY     NOT NULL,
          NAME           TEXT    NOT NULL,
          AGE            INT     NOT NULL,
          ADDRESS        CHAR(50),
          SALARY         REAL
          );\n"
    expect "sqlite>"
    send ".read ../common/insert.txt\n"
    expect "sqlite>"
    send ".backup ./db.bak\n"
    expect "sqlite>"
    send "delete from COMPANY;\n"
    expect "sqlite>"
    send ".output ./output.txt\n"
    expect "sqlite>"
    send "select *from COMPANY;\n"
    expect "sqlite>"
    send ".restore ./db.bak\n"
    expect "sqlite>"
    send ".output ./output1.txt\n"
    expect "sqlite>"
    send "select *from COMPANY;\n"
    expect "sqlite>"
    send ".quit\n"
    expect eof
END
    CHECK_RESULT "$(wc -l ./output.txt | grep -cE "0")" 1
    CHECK_RESULT "$(wc -l ./output1.txt | grep -cE "24")" 1
    LOG_INFO "End to run test."
}
function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf ./db.bak ./output* ./test.db
    LOG_INFO "End to restore the test environment."
}
main "$@"
