#!/bin/sh


JOB_LIST=$1
SERVER=$2
FILE=$3 #store info about trigger
#LOG_FILE=$3
#JOB_LIST="AOS_10.x_R58MC34H3PE_Note10 AOS_9.x_R58M87CHVDV_Note9"
#SERVER=http://10.254.194.36:8080/job/Jobs%20Base%20On%20Device/view/LADM/job
#FILE="info_2020-08-09-19_57"


echo "[CheckStatus] START"
echo "[CheckStatus] For $JOB_LIST"
echo "[CheckStatus] On $SERVER"

declare -i count=0

for job in $JOB_LIST;do

  #Define what is last build of a job bases on Info File
  BUILD_LIST=`grep -E "JOB-$job" $FILE.txt|sed -E 's/.+BUILD#//g'|cut -d "-" -f1`
#  array_list="$IFS"
  IFS=' ' read -r -a array <<< "$BUILD_LIST"

  declare -i a=${#array[@]}

  echo "[CheckStatus] Array List: "
  # shellcheck disable=SC2145
  echo "\t\t\t ${array[@]}"
  echo "[CheckStatus] Size: $a"
  lastBuild=${array[a-1]}
  echo "[CheckStatus] Last Build of Job $job is $lastBuild"

  STATUS=`curl --silent $SERVER/$job/$lastBuild/api/json|grep -E "result"|sed -E 's/.+result\"://g'|cut -d "," -f1`

  echo "[CheckStatus] Job $job is $STATUS"

  while [[ $STATUS == "null" || $STATUS = "" ]]
  do
    sleep 180
    count=$((count+1))
    # shellcheck disable=SC2039
    if [[ $count == 3 ]]
    then
      echo "Waiting for cycle 2 minutes"
      count=0
    fi
    STATUS=`curl --silent $SERVER/$job/$lastBuild/api/json|grep -E "result"|sed -E 's/.+result\"://g'|cut -d "," -f1`
  done

done
echo "[CheckStatus] All Jobs are DONE"
echo "[CheckStatus] END"