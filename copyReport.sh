#!/bin/sh
#========================================================================================#
#   Copy Report To Folder:
#   Happen For Each Release
#   Input: Report Link File that listed all neccessary link of Report following Adstyle
#
#========================================================================================#

source=$1
destination=$2
FLAG_SRC=false
FLAG_DES=false
FILE="Report_2020-08-07.txt"
echo "Prepare Data before copying"

echo "$FILE"|grep -E "http"

#if [[  -d "$source" ]]
#then
#  echo "Source is Existed - $source"
#  FLAG_SRC=true
#else
#  echo "Source is NOT Existed - $source"
#fi
#
#if [[  -d "$destination" ]]
#then
#  echo "Destination is Existed - $destination"
#  FLAG_DES=true
#else
#  echo "Destination is NOT Existed - $destination"
#fi

#Process Data File
#Structure
# OS
# ANDROID
# Device 1
#     ADSTYLE1
#         InventoryKey1
#         ........
#         InventoryKeyN
#     ....
#     ADSTYLEN
#IOS
#DEVICE 1


#if [[ $FLAG_SRC == true && $FLAG_DES == true ]]
#then
#  input=$source
#  output=$destination
#  echo "Copying is starting with:\nSource: $input\nDestination: $output"
#  rsync -uav "$input" "$output"
#
#fi




