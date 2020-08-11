#!/bin/bash


echo "====================================================================="
JOBLIST="$JOBLIST_AOS,$JOBLIST_IOS"
echo "[Jenkin] Value of job_name_list is $JOBLIST"
JOBLIST=`sed -E 's/\,/ /g' <<< $JOBLIST`
echo "[Jenkin] After parse $JOBLIST"
echo "====================================================================="
echo "[Jenkin] Adstyle_1: $ADSTYLE_1"

echo "[Jenkin] Inventory Key List 1: $INVENTORYKEY_LIST_1"


if [[ -z "$ADSTYLE_1" ]]
then
    sub_list_1=""
    echo "[Jenkin] Adstyle_1 Empty"
else
    if [[ -z "$INVENTORYKEY_LIST_1" ]]
    then
		    sub_list_1=""
        echo "[Jenkin] INVENTORYKEY_LIST_1 Empty"
    else
		    INVENTORYKEY_LIST_1=`sed -E 's/\,/ /g' <<< $INVENTORYKEY_LIST_1`
		    echo "[Jenkin] After parse $INVENTORYKEY_LIST_1"
    	  sub_list_1="$ADSTYLE_1($INVENTORYKEY_LIST_1)"
    fi
fi

echo "[Jenkin] SubList 1: $sub_list_1"

echo "====================================================================="

echo "[Jenkin] Adstyle_2: $ADSTYLE_2"
echo "[Jenkin] Inventory Key List 2: $INVENTORYKEY_LIST_2"


if [[ -z "$ADSTYLE_2" ]]
then
    sub_list_2=""
    echo "[Jenkin] Adstyle_2 Empty"
else
    if [[ -z "$INVENTORYKEY_LIST_2" ]]
    then
		    sub_list_2=""
        echo "[Jenkin] INVENTORYKEY_LIST_2 Empty"
    else
		    INVENTORYKEY_LIST_2=`sed -E 's/\,/ /g' <<< $INVENTORYKEY_LIST_2`
		    echo "[Jenkin] After parse $INVENTORYKEY_LIST_2"
    	  sub_list_2="$ADSTYLE_2($INVENTORYKEY_LIST_2)"
    fi
fi


echo "[Jenkin] SubList 2: $sub_list_2"



echo "====================================================================="

#need to check if one of adstyle is empty
ADSTYLE_SIZE=2

ADSTYLE_KEY_LIST="$sub_list_1 $sub_list_2"
ADSTYLE_KEY_LIST=`echo $ADSTYLE_KEY_LIST|sed -E 's/) /)/g'`

echo "[Jenkin] ADSTYLE_KEY_LIST: $ADSTYLE_KEY_LIST"
echo "[Jenkin] Auto Trigger Test For ADSTYLEs have different INVENTORY KEY list"
echo "[Jenkin] Current Path: "
pwd

chmod 777 AutoTriggerDiffKeyList.sh addComment.sh checkJobListFinish.sh triggerList.sh AddCommentToLastBuild.sh


./AutoTriggerDiffKeyList.sh "$SERVER" "$JOBLIST" "$BRANCH" "$PLANID" "$PHASE" "$ADSTYLE_KEY_LIST" "$ADSTYLE_SIZE" "$STATUS_TO_TEST"

#Get OS For Description
if [[ ! -z "$JOBLIST_AOS" ]]
then
	OS="Android"
    if [[ ! -z "$JOBLIST_IOS" ]]
    then
        OS="$OS & IOS"
    fi
elif [[ ! -z "$JOBLIST_IOS" ]]
then
	OS="IOS"
else
	echo "[Jenkin] OS is not defined !"
fi

echo "[Jenkin] OS: $OS"
echo "[Jenkin] Current Jenkin Job: $JOB_BASE_NAME"

./AddCommentToLastBuild.sh $JOB_BASE_NAME "$PLANID" "$ADSTYLE_LIST" "$OS"