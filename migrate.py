"""
迁移一般要修改的文件：
1.dep_install.sh
2.
"""

import os
import argparse
import re

def delete_files(directory, file_name):
    """
    在指定的目录中删除所有包含指定文件名的文件。

    :param directory: 要搜索的目录的路径。
    :param file_name: 要删除的文件名。
    """
    # 遍历目录中的所有文件和子目录
    for root, dirs, files in os.walk(directory):
        for file in files:
            # 如果文件名包含指定名称，则删除文件
            if file_name in file:
                os.remove(os.path.join(root, file))
                print("已删除文件: ", os.path.join(root, file))

def replace_content(directory, pattern, replacement):
    """
    在指定的目录中遍历所有指定扩展名的文件，将文件中匹配指定模式的内容替换为指定的字符串。

    :param directory: 要搜索的目录的路径。
    :param pattern: 要匹配的模式。
    :param replacement: 要替换为的字符串。
    """
    # 遍历目录中的所有文件和子目录
    for root, dirs, files in os.walk(directory):
        for file in files:
            # 如果文件名以指定扩展名结尾，则替换文件中的内容
            # if file.endswith(file_extension):
            file_path = os.path.join(root, file)
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            new_content = re.sub(pattern, replacement, content)
            with open(file_path, 'w') as f:
                f.write(new_content)

            print("已替换文件: ", file_path)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Delete files with specified names and replace content in files in a directory')
    parser.add_argument('-d', '--dir', type=str, help='directory to search')
    parser.add_argument('-n', '--name', type=str, help='file name to delete')
    parser.add_argument('-D', '--delete', action='store_true', help='delete files that match the specified name')
    parser.add_argument('-p', '--pattern', type=str, help='pattern to search for in files')
    parser.add_argument('-r', '--replacement', type=str, help='replacement string')
    parser.add_argument('-R', '--replace', action='store_true', help='replace content in files that match the specified extension and pattern')

    args = parser.parse_args()

    parser.usage = '''
    python migrate.py -d <directory> -n <file_name> -e <file_extension> -p <pattern> -r <replacement> [-D] [-R]

    删除指定名称的文件并替换目录中指定文件扩展名中匹配指定模式的内容为指定字符串。

    参数说明：
    -d, --dir          要搜索的目录的路径。
    -n, --name         要删除的文件名。
    -p, --pattern      要匹配的模式，可以是正则表达式。
    -r, --replacement  要替换为的字符串。
    -D, --delete       如果设置了该参数，则删除所有包含指定文件名的文件。
    -R, --replace      如果设置了该参数，则替换所有指定扩展名中匹配指定模式的内容为指定字符串。

    Usage1:
        python3 migrate.py -D -d <directory> -n <file name(s)>
    Example:
        python3 migrate.py -D -d suite2cases/ -n riscv.json
    
    Usage2:
        python3 migrate.py -R -d <directory> -p <pattern> -r <replacement>
    Example:
        python3 migrate.py -R -d testcases/ -p "uname -r.*?\n" -r  "cat /etc/os-release | grep -i 'openeuler\|anolis'\n"
    '''

    if not os.path.isdir(args.dir):
        print(f"{args.dir} is not a valid directory!")
        exit()

    # 如果设置了 -D 参数，则调用 delete_files 函数删除指定文件
    if args.delete:
        delete_files(args.dir, args.name)

    # 如果设置了 -R 参数，则调用 replace_content 函数替换文件内容
    if args.replace:
        replace_content(args.dir, args.pattern, args.replacement)