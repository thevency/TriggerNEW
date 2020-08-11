#!/bin/sh

# Inventory should consist with ADSTYLE
# Log of shell script is log_AOS_ManageJobDifferentListKey.txt
# Report Data is dataReport.txt

SERVER=$1
JOB_LIST=$2
BRANCH=$3
PlanID_VALUE=$4
PHASE_VALUE=$5
ADSTYLE_KEY_LIST=$6
ADSTYLE_SIZE=$7
STATUS_TO_TEST=$8

#example of ADSTYLE_KEY_LIST: BannerView2_Image_600x314(lb.3JR3g_Z3yoU) IconView_Image_600x314-540x540(lb.oLFjKT8kJDo)

ADSTYLE_FILE="/Users/lw11996/.jenkins/adstyle_aos.properties"
LOG_FILE="log_AutoTriggerDiffListKey_`date +"%Y-%m-%d-%H:%M"`"
REPORT_FILE=""

name_of_report=`date +"%Y-%m-%d-%H:%M"`

echo "[AutoTriggerDiffListKey] Parameters"
echo "[AutoTriggerDiffListKey] 1. SERVER: $SERVER"
echo "[AutoTriggerDiffListKey] 2. JOB_LIST: $JOB_LIST"
echo "[AutoTriggerDiffListKey] 3. BRANCH: $BRANCH"
echo "[AutoTriggerDiffListKey] 4. PlanID_VALUE: $PlanID_VALUE"
echo "[AutoTriggerDiffListKey] 5. PHASE_VALUE: $PHASE_VALUE"
echo "[AutoTriggerDiffListKey] 6. ADSTYLE_KEY_LIST: $ADSTYLE_KEY_LIST"
echo "[AutoTriggerDiffListKey] 7. ADSTYLE_SIZE: $ADSTYLE_SIZE"
echo "[AutoTriggerDiffListKey] 8. STATUS_TO_TEST: $STATUS_TO_TEST"

RAW_STYLE=`sed -E 's/ /-/g' <<< $ADSTYLE_KEY_LIST`
RAW_STYLE=`sed -E 's/)-/) /g' <<< $RAW_STYLE`

echo "[AutoTriggerDiffListKey] RAW_STYLE: $RAW_STYLE"
ADSTYLE_KEY_LIST="$RAW_STYLE"
for i in $ADSTYLE_KEY_LIST;do
  echo "[AutoTriggerDiffListKey] START "
  echo "[AutoTriggerDiffListKey] SET DATA: $i"
  # shellcheck disable=SC2006
  style=`echo "$i"|sed -E 's/\(.+//g'`
  # shellcheck disable=SC2006
  raw_key_list=`echo "$i"|sed -E 's/.+\(//g'|cut -d ")" -f1`
  key_list=`echo $raw_key_list|sed -E 's/-/ /g'`
  InventoryKey_list="$key_list"
  echo "[AutoTriggerDiffListKey] Style After Parsed: $style"
  echo "[AutoTriggerDiffListKey] Key List After Parsed: $InventoryKey_list"
  for key in $InventoryKey_list;do
    echo "[AutoTriggerDiffListKey] Trigger for key: $key"
#    PlanID_VALUE=$1
#    STYLE_VALUE=$2
#    InventoryKey=$3
#    PHASE_VALUE=$4
    # shellcheck disable=SC2086
    ./triggerList.sh "$PlanID_VALUE" "$style" "$key" "$PHASE_VALUE" "${JOB_LIST[@]}" "$SERVER" "$BRANCH" $STATUS_TO_TEST
    sleep 120
  done
  echo "[AutoTriggerDiffListKey] Trigger Of $style is DONE"


#================2. Add comment & Get Report Info ===========
set -f
InventoryKey_array=(${InventoryKey_list// / })
  echo "[AutoTriggerDiffListKey] Prepare Data For Comment & Report ...start"
  STYLE_VALUE=$style
  FILE_INFO="info_$style`date +"%Y-%m-%d-%H:%M"`"  #Use For Prepare data
  echo "" > $FILE_INFO.txt

  for job in $JOB_LIST;do

    BUILD=`curl --user admin:116bbb186c1d12518b67f8030236d8c73a --silent $SERVER/$job/lastBuild/api/json|grep -E '#'|sed -E 's/.+\#//g'|cut -d"\"" -f1`

    BUILD_2=$BUILD

    # shellcheck disable=SC2039
    OS_VALUE=`cut -d "_" -f2 <<< "$job"`

    echo "[AutoTriggerDiffListKey] InventoryKey List Size: ${#InventoryKey_list[@]}"

  for (( a=0; a < ${#InventoryKey_array[@]}; a++ ));do
      BUILD_LIST+="$BUILD "
      BUILD=$((BUILD+1))
    done

    echo "[AutoTriggerDiffListKey] BUILD LIST: $BUILD_LIST"

    echo "JOB-$job--BUILD#$BUILD_LIST-STYLE#$STYLE_VALUE" >> $FILE_INFO.txt

    for key in "${InventoryKey_list[@]}";do
      echo "$job#$BUILD_2#Test on Plan $PlanID_VALUE - OS $OS_VALUE - Style $style - Inventory $key"  >> $FILE_INFO.txt
      BUILD_2=$((BUILD_2+1))
    done
    BUILD_LIST=()
  done

  echo "[AutoTriggerDiffListKey] Prepare Data For Comment & Report ...end"

  echo "Phase Value is $PHASE_VALUE"
  if [[ $PHASE_VALUE == "2" ]]
  then
    echo "[AutoTriggerDiffListKey] Check For Ad style finish ..."
    STATUS_OF_ADSTYLE=`grep "$style" $ADSTYLE_FILE|sed -E 's/.+'$style'//g'|cut -d "=" -f2`
    while [[ $STATUS_OF_ADSTYLE != "true" ]]
    do
      sleep 300
      echo "[AutoTriggerDiffListKey] Waiting with cycle 2 minutes..."
    done
  else
    echo "[AutoTriggerDiffListKey] Phase 1 is trigger ....Check All Job Is Finished ?"
    # ======== For COMMENT & DATA =============
  fi

  echo "[AutoTriggerDiffListKey] Call addComment.sh"
  ./addComment.sh "$SERVER" "${JOB_LIST[@]}" "$FILE_INFO"

done

echo "[AutoTriggerDiffListKey] END"