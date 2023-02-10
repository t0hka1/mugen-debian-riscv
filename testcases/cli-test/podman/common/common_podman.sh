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
# @Author    :   liujingjing
# @Date      :   2021/01/11
# @License   :   Mulan PSL v2
# @Desc      :   Public class integration
#####################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function deploy_env() {
    uname -r | grep 'oe\|an' 
    if [ $? -eq 0 ]; then  
        DNF_INSTALL "podman podman-docker" 
    else 
        APT_INSTALL "podman podman-docker" 
    fi
    echo -e "[registries.search]
registries = ['docker.io']

[registries.insecure]
registries = []

[registries.block]
registries = []
" >/etc/containers/registries.conf
}

function clear_env() {
    podman stop postgres
    podman rm -all
    podman rmi -f -all
    APT_REMOVE
}
