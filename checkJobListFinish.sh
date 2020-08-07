#!/bin/sh


JOB_LIST=$1
SERVER=$2
#LOG_FILE=$3


# shellcheck disable=SC2086
echo "[CheckStatus] START"

for job in $JOB_LIST;do

  STATUS=`curl --silent $SERVER/$job/lastBuild/api/json|grep -E "result"|sed -E 's/.+result\"://g'|cut -d "," -f1`

  echo "[CheckStatus] Job $job is $STATUS"

  while [[ $STATUS == "null" ]]
  do
    echo "Waiting for cycle 10 minutes"
    sleep 600
  done

done
echo "[CheckStatus] All Jobs are DONE"
echo "[CheckStatus] END"

