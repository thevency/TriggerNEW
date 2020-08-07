#!/bin/sh

# Inventory should consist with ADSTYLE
SERVER=$1
OS=$2
JOB_LIST=$3
BRANCH=$4
PlanID_VALUE=$5
PHASE_VALUE=$6
ADSTYLE_LIST=$7
InventoryKey_list="$8"
STATUS_TO_TEST=$9

echo "[AutoTriggerSameKey] Parameters"
echo "[AutoTriggerSameKey] 1. SERVER: $SERVER"
echo "[AutoTriggerSameKey] 2. OS: $OS"
echo "[AutoTriggerSameKey] 3. JOB_LIST: $JOB_LIST"
echo "[AutoTriggerSameKey] 4. BRANCH: $BRANCH"
echo "[AutoTriggerSameKey] 5. PlanID_VALUE: $PlanID_VALUE"
echo "[AutoTriggerSameKey] 6. PHASE_VALUE: $PHASE_VALUE"
echo "[AutoTriggerSameKey] 7. ADSTYLE_LIST: $ADSTYLE_LIST"
echo "[AutoTriggerSameKey] 8. InventoryKey_list: $InventoryKey_list"
echo "[AutoTriggerSameKey] 9. STATUS_TO_TEST: $STATUS_TO_TEST"



ADSTYLE_FILE="/Users/lw11996/.jenkins/adstyle_aos.properties"
LOG_FILE="log_AutoTriggerSameListKey_`date +"%Y-%m-%d-%H:%M"`"
#SERVER=http://10.254.194.36:8080/job/Jobs%20Base%20On%20Device/view/LADM/job
#OS="android"
#JOB_LIST="AOS_10.x_R58MC34H3PE_Note10 iOS_12.x_3cd794dc710325abb8881184106b1eb0fccb2099_XS"
#BRANCH="origin/ladm"
#PlanID_VALUE=""
#PHASE_VALUE="1"
#InventoryKey_list="lb.nYuXlQJ4blY lb.cNcwLKQbbNQ"
#ADSTYLE_LIST="Union_Image_1200x628"
#STATUS_TO_TEST=""
#ADSTYLE_FILE="/Users/lw11996/.jenkins/adstyle_aos.properties"
#LOG_FILE="log_AutoTriggerSameListKey_`date +"%Y-%m-%d-%H:%M"`"


#=============1. Trigger Jobs ========================
#Clean file
#echo "" > $LOG_FILE.txt

#Only applied for Adstyles that have same inventory key list.
for style in $ADSTYLE_LIST;do
  echo "======================================\nTrigger Ad style: $style for all keys at `date +"%Y-%m-%d-%H:%M"`"
  # shellcheck disable=SC2086
  echo "[AutoTriggerSameKey] TestPlanID: $PlanID_VALUE\n[AutoTriggerSameKey] AD_STYLE: $style"

  for key in $InventoryKey_list;do
    # shellcheck disable=SC2086
    echo "[AutoTriggerSameKey] Trigger for key: $key" >> $LOG_FILE.txt
#    triggerList_AOS.sh: PlanID_VALUE=$1 STYLE_VALUE=$2 InventoryKey=$3 PHASE_VALUE=$4 JOB_LIST=$5 SERVER=$6 LOG=$7 $branch=$8
    ./triggerList.sh $PlanID_VALUE $style $key $PHASE_VALUE "${JOB_LIST[@]}" "$SERVER" "$LOG_FILE" $BRANCH $OS $STATUS_TO_TEST
    sleep 120
  done

  echo "[AutoTriggerSameKey] Finish Trigger Ad style $style"

#================2. Add comment & Get Report Info ===========

#JOB_LIST="AOS_10.x_R58MC34H3PE_Note10 AOS_8.x_1cb3e90b1b027ece_S9Plus"
#InventoryKey_list=("lb.nYuXlQJ4blY" "lb.cNcwLKQbbNQ")
set -f
InventoryKey_array=(${InventoryKey_list// / })


echo "[AutoTriggerSameKey] Prepare Data For Comment & Report ...start"
STYLE_VALUE=$style
FILE_INFO="info_$style_`date +"%Y-%m-%d-%H:%M"`"  #Use For Prepare data

echo "" > $FILE_INFO.txt

for job in $JOB_LIST;do

  BUILD=`curl --user admin:116bbb186c1d12518b67f8030236d8c73a --silent $SERVER/$job/lastBuild/api/json|grep -E '#'|sed -E 's/.+\#//g'|cut -d"\"" -f1`

  BUILD_2=$BUILD

  OS_VALUE=`cut -d "_" -f2 <<< "$job"`



  echo "[AutoTriggerSameKey] InventoryKey list SIZE: ${#InventoryKey_array[@]}"

  for (( a=0; a < ${#InventoryKey_array[@]}; a++ ));do
    BUILD_LIST+="$BUILD "
    BUILD=$((BUILD+1))
  done

  echo "[AutoTriggerSameKey] BUILD LIST: $BUILD_LIST"

  echo "JOB-$job--BUILD#$BUILD_LIST-STYLE#$STYLE_VALUE" >> "$FILE_INFO".txt

  for key in "${InventoryKey_array[@]}";do
    echo "$job#$BUILD_2#Test on Plan $PlanID_VALUE - OS $OS_VALUE - Style $style - Inventory $key"  >> "$FILE_INFO".txt
    BUILD_2=$((BUILD_2+1))
  done

  BUILD_LIST=()
done
echo "[AutoTriggerSameKey] Prepare Data For Comment & Report ...end"
echo "[AutoTriggerSameKey] Check For Ad style finish ..."

#============== Check AD STYLE FINISH ==========================
#Phase 2: It is required to check if current Adstyle is finished.
  if [[ $PHASE_VALUE == "2" ]]
  then
    STATUS_OF_ADSTYLE=`grep "$style" $ADSTYLE_FILE|sed -E 's/.+'$style'//g'|cut -d "=" -f2`

    while [[ $STATUS_OF_ADSTYLE != "true" ]]
    do
      sleep 900
      echo "[AutoTriggerSameKey] Waiting with cycle 15 minutes"
    done

    if [[ $STATUS_OF_ADSTYLE == "true" ]]
    then
      echo "[AutoTriggerSameKey] Trigger next style"
      # shellcheck disable=SC2086
      echo "[AutoTriggerSameKey] =================="
    else
      echo "[AutoTriggerSameKey] May be a problem here - STATUS_OF_ADSTYLE: $STATUS_OF_ADSTYLE"
    fi
  else
    #Phase1: Wait until all job of current style finish
    echo "[AutoTriggerSameKey] Phase 1 is trigger ...."
#    sleep 60
#    # shellcheck disable=SC2039
#    ./checkJobListFinish.sh "${JOB_LIST[@]}" $SERVER
#    echo "[AutoTriggerSameKey] ====================="  >> $LOG_FILE.txt
  fi

  ./addComment.sh "$SERVER" "${JOB_LIST[@]}" "$FILE_INFO"
done







