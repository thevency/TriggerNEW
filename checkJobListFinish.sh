#!/bin/sh


JOB_LIST=$1
SERVER=$2
#LOG_FILE=$3



echo "[CheckStatus] START"
echo "[CheckStatus] For $JOB_LIST"
echo "[CheckStatus] On $SERVER"

declare -i count=0

for job in $JOB_LIST;do

  STATUS=`curl --silent $SERVER/$job/lastBuild/api/json|grep -E "result"|sed -E 's/.+result\"://g'|cut -d "," -f1`

  echo "[CheckStatus] Job $job is $STATUS"

  while [[ $STATUS == "null" ]]
  do
    sleep 120
    count=$((count+1))
    # shellcheck disable=SC2039
    if [[ $count == 3 ]]
    then
      echo "Waiting for cycle 2 minutes"
      count=0
    fi
    STATUS=`curl --silent $SERVER/$job/lastBuild/api/json|grep -E "result"|sed -E 's/.+result\"://g'|cut -d "," -f1`
  done

done
echo "[CheckStatus] All Jobs are DONE"
echo "[CheckStatus] END"
