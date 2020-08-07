#!/bin/sh

PlanID_VALUE=$1
STYLE_VALUE=$2
InventoryKey=$3
PHASE_VALUE=$4
ListJob=$5
SERVER=$6
FILE_NAME=$7
BRANCH_VALUE=$8
OS_VALUE=$9
STATUS_TO_TEST=${10}

#Print out data input
echo "\n======= Log_of_Trigger_A_ListJob =======" >> $FILE_NAME.txt
echo "Input Data For Trigger Job: \n1. PlanID_VALUE: $PlanID_VALUE\n2. STYLE_VALUE: $STYLE_VALUE\n"
echo "3. InventoryKey: $InventoryKey\n4. PHASE_VALUE: $PHASE_VALUE\n5. ListJob: $ListJob\n6. SERVER: $SERVER\n"

#========== Trigger Job in list =================
echo "[TRIGGER] START "
for i in $ListJob;do
  JOB_NAME=$i
  echo "[TRIGGER] For $i"
  curl -X POST --user admin:116bbb186c1d12518b67f8030236d8c73a --silent "$SERVER/$JOB_NAME/buildWithParameters?BRANCH=$BRANCH_VALUE&ForTestCases=$STATUS_TO_TEST&PlanID=$PlanID_VALUE&AD_STYLE=$STYLE_VALUE&Phase=Phase$PHASE_VALUE&InventoryKey=$InventoryKey"
done
echo "[TRIGGER] END \n"








#SERVER=http://10.254.194.36:8080/job/Jobs%20Base%20On%20Device/view/LADM/job
#ListJob="AOS_10.x_R58MC34H3PE_Note10 "
#FILE_NAME="Log_Of_TriggerList"
## ====== Prepare info File ==================
#FILE_INFO="info"
#for i in $ListJob;do
#  BUILD_NUMBER=`curl --user admin:116bbb186c1d12518b67f8030236d8c73a --silent $SERVER/$JOB_NAME/lastBuild/api/json|grep -E '#'|sed -E 's/.+\#//g'|cut -d"\"" -f1`
#  echo "$JOB_NAME--BUILD#$BUILD_NUMBER#Test on plan $PlanID_VALUE - OS $OS_VALUE - Style $STYLE_VALUE - Inventory $InventoryKey" >> FILE_INFO.txt
#done


