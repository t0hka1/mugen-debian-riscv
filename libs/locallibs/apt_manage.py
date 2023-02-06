# -*- coding: utf-8 -*-

import os
import sys
import subprocess
import tempfile
import argparse

SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__))
sys.path.append(SCRIPT_PATH)
import mugen_log
import ssh_cmd


def local_cmd(cmd, conn=None):
    """本地命令执行

    Args:
        cmd ([str]): 需要执行的命令
        conn ([class], optional): 建立和远端的连接. Defaults to None.

    Returns:
        [list]: 命令执行后的返回码，命令执行结果
    """
    exitcode, output = subprocess.getstatusoutput(cmd)
    return exitcode, output


def apt_install(pkgs, node=1, tmpfile=""):
    """安装软件包

    Args:
        pkgs ([str]): 软包包名，"bc" or "bc vim"
        node (int, optional): 节点号. Defaults to 1.
        tmpfile (str, optional): 软件包及其依赖包的缓存文件. Defaults to "".

    Returns:
        [list]: 错误码，安装的包的列表
    """
    if pkgs == "":
        mugen_log.logging("error", "the following arguments are required:pkgs")
        sys.exit(1)

    localtion = os.environ.get("NODE" + str(node) + "_LOCALTION")
    if localtion == "local":
        conn = None
        func = local_cmd
    else:
        conn = ssh_cmd.pssh_conn(
            os.environ.get("NODE" + str(node) + "_IPV4"),
            os.environ.get("NODE" + str(node) + "_PASSWORD"),
            os.environ.get("NODE" + str(node) + "_SSH_PORT"),
            os.environ.get("NODE" + str(node) + "_USER"),
        )
        func = ssh_cmd.pssh_cmd

    result = func(conn=conn, cmd="apt -y install "+pkgs)[1]
    if "is already " in result : # TODO:find more case
        mugen_log.logging("info", "pkgs:(%s) is already installed" % pkgs)
        return 0, None

    if "Unable to locate package" in result:
        split_result = result.split('\n')
        for row in split_result:
            if "Unable to locate package" in row:
                lost_pkgs = row.replace("E: Unable to locate package ",'')
        mugen_log.logging("Error", "pkgs:(%s) not found" % lost_pkgs)
        return 0, None

    exitcode, result = func(conn=conn, cmd="apt -y install " + pkgs)

    if tmpfile == "":
        tmpfile = tempfile.mkstemp(dir="/tmp")[1]

    with open(tmpfile, "a+") as f:
        f.write(pkgs + " ")

    if exitcode == 0:
        result = f.name

    return exitcode, result


def apt_remove(node=1, pkgs="", tmpfile=""):
    """卸载软件包

    Args:
        node (int, optional): 节点号. Defaults to 1.
        pkgs (str, optional): 需要卸载的软件包. Defaults to "".
        tmpfile (str, optional): 安装时所有涉及的包. Defaults to "".

    Returns:
        list: 错误码，卸载列表或错误信息
    """
    if pkgs == "" and tmpfile == "":
        mugen_log.logging(
            "error", "Packages or package files these need to be removed must be added"
        )
        sys.exit(1)

    localtion = os.environ.get("NODE" + str(node) + "_LOCALTION")
    if localtion == "local":
        conn = None
        func = local_cmd
    else:
        conn = ssh_cmd.pssh_conn(
            os.environ.get("NODE" + str(node) + "_IPV4"),
            os.environ.get("NODE" + str(node) + "_PASSWORD"),
            os.environ.get("NODE" + str(node) + "_SSH_PORT"),
            os.environ.get("NODE" + str(node) + "_USER"),
        )
        func = ssh_cmd.pssh_cmd

    pkgList = ""
    if tmpfile != "":
        with open(tmpfile, "r") as f:
            pkgList = f.read()

    exitcode = func(conn=conn, cmd="apt -y autoremove " + pkgs + " " + pkgList)[0]
    if localtion != "local":
        ssh_cmd.pssh_close(conn)
    return exitcode


if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        usage="apt_manage.py install|remove [-h] [--node NODE] [--pkgs PKG] [--tempfile TEPMFILE]",
        description="manual to this script",
    )
    parser.add_argument(
        "operation", type=str, choices=["install", "remove"], default=None
    )
    parser.add_argument("--node", type=int, default=1)
    parser.add_argument("--pkgs", type=str, default="")
    parser.add_argument("--tempfile", type=str, default="")
    args = parser.parse_args()

    if sys.argv[1] == "install":
        exitcode, output = apt_install(args.pkgs, args.node, args.tempfile)
        if output is not None:
            print(output)
        sys.exit(exitcode)
    elif sys.argv[1] == "remove":
        exitcode = apt_remove(args.node, args.pkgs, args.tempfile)
        sys.exit(exitcode)
    else:
        mugen_log.logging(
            "error",
            "usage: apt_manage.py install|remove [-h] [--node NODE] [--pkg PKG] [--tempfile TEPMFILE]",
        )
        sys.exit(1)
