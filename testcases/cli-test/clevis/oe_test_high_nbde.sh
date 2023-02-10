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
# @Date      :   2020/04/26
# @License   :   Mulan PSL v2
# @Desc      :   Deploying high-availability NBDE systems
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function config_params() {
    LOG_INFO "Start loading data!"
    TEST_DISK="/dev/$(TEST_DISK 1)"
    LOG_INFO "Loading data is complete!"
}

function pre_test() {
    LOG_INFO "Start environmental preparation."
    uname -r | grep 'oe\|an' 
    if [ $? -eq 0 ]; then  
        DNF_INSTALL "tang clevis clevis-dracut cryptsetup-reencrypt clevis-udisks2" 
    else 
        APT_INSTALL "tang clevis clevis-dracut cryptsetup-reencrypt clevis-udisks2" 
    fi
    uname -r | grep 'oe\|an' 
    if [ $? -eq 0 ]; then  
        DNF_INSTALL tang 2 
    else 
        APT_INSTALL tang 2 
    fi
    echo -e "n\n\np\n\n\n+100M\nw"| fdisk "${TEST_DISK}"
    ls /mnt/test_encrypted && rm -rf /mnt/test_encrypted
    mkdir /mnt/test_encrypted
    ls /etc/systemd/system/tangd.socket.d && rm -rf /etc/systemd/system/tangd.socket.d
    SOCKET_CONTENT='[Socket]\nListenStream=\nListenStream=8009'
    mkdir /etc/systemd/system/tangd.socket.d
    echo -e ${SOCKET_CONTENT} > /etc/systemd/system/tangd.socket.d/override.conf
    UUID=$(uuidgen)
    LOG_INFO "End of environmental preparation!"
}

function run_test() {
    LOG_INFO "Start executing testcase."
    echo -e "\n\n"|cryptsetup-reencrypt --type luks1 --new --reduce-device-size 8M "${TEST_DISK}"1
    CHECK_RESULT $? 0 0 "Disk encryption failed"
    echo -e "\n"|cryptsetup open "${TEST_DISK}"1 test_encrypted
    CHECK_RESULT $? 0 0 "Disk mapping failed"
    mkfs.ext4 /dev/mapper/test_encrypted -F
    mount /dev/mapper/test_encrypted /mnt/test_encrypted
    CHECK_RESULT $? 0 0 "Disk mount failed"
    cryptsetup luksHeaderBackup ${TEST_DISK}1 --header-backup-file /tmp/header.bin
    CHECK_RESULT $? 0 0 "Backup luksHeader information failed"
    SLEEP_WAIT 2
    systemctl enable tangd.socket
    CHECK_RESULT $? 0 0 "Failed to enable tangd.socket service"
    systemctl daemon-reload
    systemctl show tangd.socket -p Listen | grep 8009
    CHECK_RESULT $? 0 0 "Failed to display the 'Listen' property of tangd.socket"
    systemctl start tangd.socket
    CHECK_RESULT $? 0 0 "Failed to start tangd.socket service"
    SSH_CMD "systemctl enable tangd.socket;mkdir /etc/systemd/system/tangd.socket.d" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    P_SSH_CMD --node 2 --cmd "echo -e [Socket]\\\nListenStream=\\\nListenStream=8009 > /etc/systemd/system/tangd.socket.d/override.conf"
    SSH_CMD "systemctl daemon-reload;systemctl show tangd.socket -p Listen | grep 8009;
    		systemctl start tangd.socket;systemctl stop firewalld;setenforce 0" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    curl http://127.0.0.1:8009/adv -o adv.jws
    SLEEP_WAIT 1
    expect -c"
        set timeout 120
        spawn luksmeta init -n -d ${TEST_DISK}1
	expect {
		\"yn\" {
			send \"y\\r\"
			exp_continue
		}
		timeout
	}
    "
    CHECK_RESULT $? 0 0 "luksmeta init failed"
    echo $luks_num | luksmeta save -d ${TEST_DISK}1 -s 0 -u $UUID
    expect -c"
	set timeout 120
        spawn clevis luks bind -d ${TEST_DISK}1 sss '{\"t\":1,\"pins\":{\"tang\":[{\"url\":\"http://127.0.0.1:8009\"},{\"url\":\"http://${NODE2_IPV4}:8009\"}]}}'
	    expect {
		\"ynYN\" {
			send \"y\\r\"
			exp_continue
		}
		\"yn\" {
            send \"y\\r\"
            exp_continue
            }
		\"assword\" {
            send \"\\r\"
            exp_continue
        }
		timeout
	}
"
    CHECK_RESULT $? 0 0 "Disk binding failed"
    expect -c"
        set timeout 120
        spawn clevis luks unbind -d ${TEST_DISK}1 -s 1
	    expect {
		\"yn\" {
			send \"y\\r\"
			exp_continue
		}
		timeout
	}
    "
    CHECK_RESULT $? 0 0 "Disk unbinding failed"
    LOG_INFO "Finish testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    umount /mnt/test_encrypted
    cryptsetup close test_encrypted
    mkfs.ext4 ${TEST_DISK}1 -F
    echo -e "d\n\nw"| fdisk "${TEST_DISK}"
    APT_REMOVE
    rm -rf secert.jwe adv.jws sec.jwe input-plain.txt /etc/systemd/system/tangd.socket.d /mnt/test_encrypted1 /var/db/tang /tmp/header.bin
    APT_REMOVE 2 "tang"
    SSH_CMD "rm -rf /etc/systemd/system/tangd.socket.d /var/db/tang" ${NODE2_IPV4} ${NODE2_PASSWORD} ${NODE2_USER}
    mkfs.ext4 ${TEST_DISK} -F
    LOG_INFO "Finish environment cleanup!"
}
main "$@"