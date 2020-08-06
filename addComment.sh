#!/bin/sh
#========================================================================================#
#   Add comment & Report Data Generation should be isolated for its simple
#   Happen when One Ad Stye Done
#========================================================================================#

SERVER=$1
JOB_LIST=$2
FILE=$3 #store info about trigger
LOG_FILE=$4
REPORT_NAME="Report_`date +"%Y-%m-%d"`"
date_info=`date`

#SERVER=http://10.254.194.36:8080/job/Jobs%20Base%20On%20Device/view/LADM/job
#JOB_LIST="AOS_10.x_R58MC34H3PE_Note10 AOS_10.x_BH9305KSDW_SOV39"


echo "========= Add Comment & Report Data ===========" >> LOG_FILE.txt
echo "====== Report Data At $date_info ======\n" >> $REPORT_NAME.txt

#0. Precondition: Current Adstyle is finished
#1. Check last build of all jobs have been done for sure
chmod 777 checkJobListFinish.sh
./checkJobListFinish.sh $SERVER "${JOB_LIST[@]}" $LOG_FILE

#2. Get Build number - Inventory key List of each Job that need to add comment

for job in $JOB_LIST;do

  echo "================================"  >> LOG_FILE.txt
  echo "Current Job: $job"  >> LOG_FILE.txt
  echo "================================"  >> LOG_FILE.txt

  BUILD_LIST=`grep -E "JOB-$job" $FILE|sed -E 's/.+BUILD#//g'|cut -d "-" -f1`
  STYLE=`grep -E "JOB-$job" $FILE|sed -E 's/.+STYLE//g'|cut -d "#" -f2`
#4 Get Report Link
  echo "........................................................" >> $REPORT_NAME.txt
  echo "\nDevice: $job\n........................................................" >> $REPORT_NAME.txt
  echo "\n\nAD-STYLE: $STYLE\n==============================" >> $REPORT_NAME.txt

  for build in $BUILD_LIST;do
    echo "Current Build: #$build"  >> LOG_FILE.txt
#3. Prepare comment
    Description=`grep -E "$job#$build" $FILE|cut -d "#" -f3`
    InventoryKey=`grep -E "$job#$build" $FILE|sed -E 's/.+Inventory//g'|cut -d " " -f2`
    echo "Description: $Description" >> LOG_FILE.txt
    curl -X POST --user admin:116bbb186c1d12518b67f8030236d8c73a --silent --data-urlencode "description=$Description" "$SERVER/$job/$build/submitDescription"
    echo "InventoryKey: $InventoryKey" >> $REPORT_NAME.txt
    echo "$SERVER/$job/$build/thucydidesReport/\n\n" >> $REPORT_NAME.txt
  done
done


echo "========= End Add Comment & Report Data ==========="  >> LOG_FILE.txt

#BUILD_NUMBER=`curl --user admin:116bbb186c1d12518b67f8030236d8c73a --silent $SERVER/$JOB_NAME/lastBuild/api/json|grep -E '#'|sed -E 's/.+\#//g'|cut -d"\"" -f1`
#echo "Report Link: $SERVER/$JOB_NAME/$BUILD_NUMBER/thucydidesReport/" >> dataReport.txt
#echo "==========================="
#for i in $ListJob;do
#  JOB_NAME=$i
#  BUILD_NUMBER=`curl --user admin:116bbb186c1d12518b67f8030236d8c73a --silent $SERVER/$JOB_NAME/lastBuild/api/json|grep -E '#'|sed -E 's/.+\#//g'|cut -d"\"" -f1`
#  echo "Gonna add comment for $JOB_NAME/$BUILD_NUMBER"
##  RunID=`curl --user admin:116bbb186c1d12518b67f8030236d8c73a --silent $SERVER/$JOB_NAME/lastBuild/consoleText|grep -E "CurrentTestRun"|sed -E 's/CurrentTestRun=//g'`
##  echo "RunID is $RunID"
#  description="Test On Plan $PlanID_VALUE - RunID $RunID - os: $OS_VALUE - Style: $STYLE_VALUE- inventory key: $InventoryKey"
#  curl -X POST --user admin:116bbb186c1d12518b67f8030236d8c73a --silent --data-urlencode "description=$description" "$SERVER/$JOB_NAME/$BUILD_NUMBER/submitDescription"
#done



