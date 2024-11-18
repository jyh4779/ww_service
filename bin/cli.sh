#!/bin/bash

#LDIF_FILE="/storenext/user/itinfra/pjm/cli.ldif"
source /app/ww_service/bin/env.sh

DIR=/storenext/user/itinfra/client_ip

CURRENT_USER=$(hostname)
CLIENTIP=$(awk '/32 host/ { print f } {f=$2}' <<< "$(</proc/net/fib_trie) " | head -1 )
USER=$(expr substr $USER 1 6)
WESTUSER=$(getent passwd $USER | awk -F ':' '{print $5}')
CPU=$(lscpu | grep Model | head -2 | tail -1)
MEMORY=$(free -m | awk '{print $2}' | head -2 | tail -1)
WE=("$USER"_"$WESTUSER")

declare -A USER_TEAM

# LDIF 파일에서 팀과 사번 정보를 파싱하여 배열에 저장
while read -r line; do
    if [[ $line == uid:* ]]; then
        uid=$(echo $line | cut -d: -f2 | tr -d ' ')
    elif [[ $line == o:* ]]; then
        team=$(echo $line | cut -d: -f2 | tr -d ' ')
        USER_TEAM[$uid]=$team
    fi
done < $LDIF_FILE

# 현재 사용자에 대해 폴더 및 파일 생성
team=${USER_TEAM[$CURRENT_USER]}

# 팀별 디렉토리 존재 여부 확인 및 생성
mkdir -p $DIR/$team
echo 성함 - $WESTUSER > $DIR/$team/$WE
echo IP 주소- $CLIENTIP >> $DIR/$team/$WE
echo 사번 - $USER >> $DIR/$team/$WE
echo CPU - $CPU >> $DIR/$team/$WE
echo 메모리 - $MEMORY'MB' >> $DIR/$team/$WE
lshw -C display 2> /dev/null >> $DIR/$team/$WE
lspci | grep -i vga >> $DIR/$team/$WE
#if [ $? -eq 0 ]; then
#    echo "현재 사용자 $CURRENT_USER의 정보가 저장되었습니다."
#else
#    echo "현재 사용자 $CURRENT_USER의 정보를 찾을 수 없습니다."
#fi
