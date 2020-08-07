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
echo "Prepare Data before copying"

if [[  -d "$source" ]]
then
  echo "Source is Existed - $source"
  FLAG_SRC=true
else
  echo "Source is NOT Existed - $source"
fi

if [[  -d "$destination" ]]
then
  echo "Destination is Existed - $destination"
  FLAG_DES=true
else
  echo "Destination is NOT Existed - $destination"
fi

#Process Data File


if [[ $FLAG_SRC == true && $FLAG_DES == true ]]
then
  input=$source
  output=$destination
  echo "Copying is starting with:\nSource: $input\nDestination: $output"
  rsync -uav "$input" "$output"

fi




