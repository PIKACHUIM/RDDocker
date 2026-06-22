#!/bin/bash

source Scripts/Titles.sh
echo "   ============================Available Version==========================="
echo "      [1] 26.04 Next Release      [ √ Now Recommend / Support Until 2031 ]  "
echo "      [2] 24.04 Noble Numbat     [ √ Now Recommend / Support Until 2029 ]  "
echo "   ========================================================================"
echo
echo -n "   Choice System Version Number(1): "
read VERSION
if [ ! $VERSION ]; then
  VERSION=1
fi
if [ $VERSION == 1 ]; then
  echo Note: VERSION='26.04'
  VERNAME='26.04'
  VERSION='26.04'
elif [ $VERSION == 2 ]; then
  echo Note: VERSION='24.04'
  VERNAME='24.04'
  VERSION='24.04'
fi


