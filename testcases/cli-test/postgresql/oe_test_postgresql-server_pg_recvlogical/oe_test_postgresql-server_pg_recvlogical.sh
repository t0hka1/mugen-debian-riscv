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
# @Author    :   wangshan
# @Contact   :   wangshan@163.com
# @Date      :   2020-10-15
# @License   :   Mulan PSL v2
# @Desc      :   pg_recvlogical
# ############################################

source ../common/lib.sh

function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    postgresql_install
    LOG_INFO "End to prepare the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    echo "wal_level = logical" >>/var/lib/pgsql/data/postgresql.conf
    CHECK_RESULT $?
    su - postgres -c "pg_ctl restart"
    CHECK_RESULT $?
    su - postgres -c "pg_recvlogical -d postgres --slot test --create-slot"
    CHECK_RESULT $?
    su - postgres -c "pg_recvlogical -d postgres --drop-slot --slot test"
    CHECK_RESULT $?
    su - postgres -c "pg_recvlogical -d postgres --slot test --create-slot --start -f - &"
    CHECK_RESULT $?
    SLEEP_WAIT 10 "pgrep -f 'slot test'" 2
    kill -9 $(pgrep -f 'slot test')
    su - postgres -c "pg_recvlogical -d postgres --drop-slot --slot test"
    su - postgres -c "pg_recvlogical -d postgres --slot test --create-slot --start  -f - -F 10 &"
    CHECK_RESULT $?
    SLEEP_WAIT 10 "pgrep -f 'slot test'" 2
    kill -9 $(pgrep -f 'slot test')
    su - postgres -c "pg_recvlogical -d postgres --drop-slot --slot test"
    CHECK_RESULT $?
    su - postgres -c "pg_recvlogical -d postgres --slot test --create-slot"
    CHECK_RESULT $?
    su - postgres -c "pg_recvlogical -d postgres --slot test --start  -f - -I 0/A3FD7168 &"
    CHECK_RESULT $?
    SLEEP_WAIT 10 "pgrep -f 'slot test'" 2
    kill -9 $(pgrep -f 'slot test')
    su - postgres -c "pg_recvlogical -d postgres --slot test --start  -n -f - &"
    CHECK_RESULT $?
    SLEEP_WAIT 10 "pgrep -f 'slot test'" 2
    kill -9 $(pgrep -f 'slot test')
    su - postgres -c "pg_recvlogical -d postgres --drop-slot --slot test"
    CHECK_RESULT $?
    su - postgres -c "pg_recvlogical -d postgres --slot test --create-slot --start -f - -s 2 -v &"
    CHECK_RESULT $?
    SLEEP_WAIT 10 "pgrep -f 'slot test'" 2
    kill -9 $(pgrep -f 'slot test')
    su - postgres -c "pg_recvlogical -d postgres --drop-slot -S test"
    CHECK_RESULT $?
    su - postgres -c "pg_recvlogical -d postgres --slot test --create-slot -h 127.0.0.1 -U postgres -w -p 5432"
    CHECK_RESULT $?
    su - postgres -c "pg_recvlogical -d postgres --drop-slot --slot test"
    CHECK_RESULT $?
    LOG_INFO "End to run test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    rm -rf /var/lib/pgsql/*
    APT_REMOVE 1 "postgresql postgresql-server postgresql-devel postgresql-contrib"
    LOG_INFO "End to restore the test environment."
}
main "$@"
