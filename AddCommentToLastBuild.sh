#!/bin/sh


JOB=$1
PLAN=$2
ADSTYLE=$3
OS=$4

SERVER=http://10.254.194.36:8080/job/Jobs%20Base%20On%20Device/view/AutoTrigger/job/
Description="Plan: $PLAN - ADSTYLE: $ADSTYLE - OS: $OS"
echo "[COMMENT] Add comment to Current Build As \n $Description"
curl -X POST --user admin:116bbb186c1d12518b67f8030236d8c73a --silent --data-urlencode "description=$Description" "$SERVER/$JOB/lastBuild/submitDescription"
echo "[COMMENT] Add comment Done"