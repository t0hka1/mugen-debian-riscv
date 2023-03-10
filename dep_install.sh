#!/usr/bin/bash
# Copyright (c) [2021] Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.
####################################
# @Author  : lemon-higgins
# @email   : lemon.higgins@aliyun.com
# @Date    : 2021-04-23 16:08:22
# @License : Mulan PSL v2
# @Version : 1.0
# @Desc    :
#####################################

usage() {
    printf "Usage:  sh dep_install.sh [options]\n
    -e: install addtitional dependencies qemu for remote testing\n
    -g shell_file: run shell file to set crocess compiliation, if have run srcipt must use source\n
    -h: print this usage info\n
    \n"
}

common_dep(){
    yum install expect psmisc make iputils python3-six python3-paramiko lshw -y
    apt install expect psmisc make python3-six python3-pip python3-paramiko lshw -y
}

anolis_dep(){
    yum install expect psmisc make iputils gcc -y
    yum install python39 -y
    ln -s -f /usr/bin/pip3.9 /etc/alternatives/pip3
    ln -s -f /usr/bin/pip-3.9 /etc/alternatives/pip-3
    ln -s -f /usr/bin/python3.9 /etc/alternatives/python3
    pip3 install paramiko -i https://pypi.tuna.tsinghua.edu.cn/simple
}


ubuntukylin_dep(){
    apt install expect psmisc make python3-six python3-pip python3-paramiko lshw -y
    pip3 install paramiko -i https://pypi.tuna.tsinghua.edu.cn/simple
}

qemu_dep(){
    echo "install qemu"
    yum install bridge-utils -y
    qemu-system-aarch64 --version && qemu-system-arm --version
    if [ $? -eq 0 ]; then
        return 0
    fi
    yum install qemu-system-aarch64 qemu-system-arm -y
    if [ $? -ne 0 ]; then
        echo "ERROR: qemu not install, you need install it youself."
        return 1
    fi
}

run_name=$0
in_qemu=0
run_shell=""

check_option(){
    had_g=0
    for opt in "$@"; do
        if [[ $opt == "-h" ]]; then
            usage
            return 0
        elif [[ $opt == "-e" ]]; then
            in_qemu=1
        elif [[ $opt == "-g" ]]; then
            had_g=1
            check_name=${run_name##*/}
            if [[ $check_name == "dep_install.sh" ]]; then
                echo "ERROR: run with crocess compiliation, must use 'source' to run script"
                return 1
            fi
        elif [ $had_g -eq 1 ]; then
            run_shell=$opt
        else
            usage
            return 1
        fi
    done

    if [[ had_g -eq 1 && run_shell == "" ]]; then
        echo "ERROR: -g parameter need"
        usage
        return 1
    fi
    return 0
}

main(){
    check_option $@
    if [ $? -ne 0 ]; then
        return 1
    fi

    uname -r | grep 'oe'
    if [ $? -eq 0 ]; then
        common_dep
        if [ $? -ne 0 ]; then
            return 1
        fi
    fi

    uname -r | grep 'an'
    if [ $? -eq 0 ]; then
        anolis_dep
        if [ $? -ne 0 ]; then
            return 1
        fi
    fi

    uname -r | grep 'gen'
    if [ $? -eq 0 ]; then
        ubuntukylin_dep
        if [ $? -ne 0 ]; then
            return 1
        fi
    fi

    if [ $in_qemu -eq 1 ]; then
        qemu_dep
        if [ $? -ne 0 ]; then
            return 1
        fi
    fi

    if [ $run_shell ]; then
        source $run_shell
        if [ $? -ne 0 ]; then
            echo "ERROR: run crocess compiliation file $run_shell fail"
            return 1
        fi
    fi

    return 0
}

main $@
