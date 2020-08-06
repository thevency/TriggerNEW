#!/bin/sh


JOB_LIST=$1
SERVER=$2
LOG_FILE=$3


# shellcheck disable=SC2086
echo "[CheckStatus] START" >> $LOG_FILE.txt

for job in $JOB_LIST;do

  STATUS=`curl --silent $SERVER/$job/lastBuild/api/json|grep -E "result"|sed -E 's/.+result\"://g'|cut -d "," -f1`

  echo "[CheckStatus] Job $job is $STATUS" >> "$LOG_FILE".txt

  while [[ $STATUS == "null" ]]
  do
    echo "Waiting for cycle 10 minutes" >> "$LOG_FILE".txt
    sleep 600
  done

done
echo "[CheckStatus] All Jobs are DONE" >> "$LOG_FILE".txt
echo "[CheckStatus] END" >> "$LOG_FILE".txt

