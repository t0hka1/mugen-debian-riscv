import re
import os 

path = "testcases/"

all_files_path=[]
for root, dirs, files in os.walk(path,topdown=False):
    if len(files)>0:
        each_foder_files=[os.path.join(root,x) for x in files]
        all_files_path.extend(each_foder_files)


for file in all_files_path:
    with open(file,errors='ignore') as f:
        content = f.read()

    new_content = re.sub(r"DNF_INSTALL (.*?)\n","uname -r | grep 'oe\|an' \n\
    if [ $? -eq 0 ]; then  \n\
        DNF_INSTALL \\1 \n\
    else \n\
        APT_INSTALL \\1 \n\
    fi\n",content)

    new_content = re.sub(r"version=\$\(rpm -qa (.*?) \| awk -F \"-\" '\{print\$2\}'\)\n","\n",new_content)

    new_content = re.sub(r"DNF_REMOVE","APT_REMOVE",new_content)

    with open(file,"w") as f:
        f.write(new_content)