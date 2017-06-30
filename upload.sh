#!/bin/bash

Cyan='\033[0;36m'
Default='\033[0;m'

commitDes=""
confirmed="n"

getCommitDes() {
    read -p "请输入提交描述: " commitDes

    if test -z "$commitDes"; then
        getCommitDes
    fi
}

getInfomation() {
getCommitDes

echo -e "\n${Default}================================================"
echo -e "  commitDes  :  ${Cyan}${commitDes}${Default}"
echo -e "================================================\n"
}

echo -e "\n"
while [ "$confirmed" != "y" -a "$confirmed" != "Y" ]
do
if [ "$confirmed" == "n" -o "$confirmed" == "N" ]; then
getInfomation
fi
read -p "确定? (y/n):" confirmed
done


git add .
git commit -m $commitDes
git push origin code

echo "finished"