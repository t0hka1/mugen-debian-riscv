#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
#@Author    	:   doraemon2020
#@Contact   	:   xcl_job@163.com
#@Date      	:   2020-10-19
#@License   	:   Mulan PSL v2
#@Desc      	:   The command rst2odt parameter coverage test of the python-docutils package
#####################################

source "${OET_PATH}"/libs/locallibs/common_lib.sh
function pre_test() {
    LOG_INFO "Start to prepare the test environment."
    uname -r | grep 'oe\|an' 
    if [$? -eq 0]; then  
        DNF_INSTALL "python-docutils" 
    else 
        APT_INSTALL "python-docutils" 
    fi
    cp -r ../common/testfile_odt.rst ./testfile.rst
    LOG_INFO "Finish preparing the test environment."
}

function run_test() {
    LOG_INFO "Start to run test."
    rst2odt --language=en-GB testfile.rst test1.odt && test -f test1.odt
    CHECK_RESULT $?
    rst2odt --record-dependencies=recordlist.log testfile.rst test2.odt && test -f test2.odt
    CHECK_RESULT $?
    test "$(rst2odt -V | awk '{print$3}')" == "$(rpm -qa python3-docutils | awk -F "-" '{print$3}')"
    CHECK_RESULT $?
    rst2odt -h | grep 'Usage'
    CHECK_RESULT $?
    rst2odt --no-doc-title testfile.rst test5.odt && test -f test5.odt
    CHECK_RESULT $?
    rst2odt --no-doc-info testfile.rst test6.odt && test -f test6.odt
    CHECK_RESULT $?
    rst2odt --section-subtitles testfile.rst test7.odt && test -f test7.odt
    CHECK_RESULT $?
    rst2odt --no-section-subtitles testfile.rst test8.odt && test -f test8.odt
    CHECK_RESULT $?
    rst2odt --pep-references testfile.rst test9.odt && test -f test9.odt
    CHECK_RESULT $?
    rst2odt --pep-base-url=http://www.abc.org/dev/peps/ testfile.rst test10.odt && test -f test10.odt
    CHECK_RESULT $?
    rst2odt --pep-file-url-template=pep-484 testfile.rst test11.odt && test -f test11.odt
    CHECK_RESULT $?
    rst2odt --rfc-references testfile.rst test12.odt && test -f test12.odt
    CHECK_RESULT $?
    rst2odt --rfc-base-url=http://www.abc.org/rfcs/ testfile.rst test13.odt && test -f test13.odt
    CHECK_RESULT $?
    rst2odt --tab-width=4 testfile.rst test14.odt && test -f test14.odt
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

function post_test() {
    LOG_INFO "Start to restore the test environment."
    APT_REMOVE "python-docutils"
    rm -rf ./*.odt ./*.rst ./*.log
    LOG_INFO "Finish restoring the test environment."
}

main "$@"
