#!/bin/bash

source Scripts/Titles.sh
echo "   ============================Available Version==========================="
echo "      [1] Debian 12 bookworm   [ √ Now Recommend / Support Until 2028 ]    "
echo "      [2] Debian 11 Bullseye   [ × Not Recommend / Support Until 2025 ]    "
echo "   ========================================================================"
echo
echo -n "   Choice System Version Number(1): "
read VERSION
if [ ! $VERSION ]; then
  echo Note: VERSION='12.4'
  VERSION='12.4'
elif [ $VERSION == 1 ]; then
  echo Note: VERSION='12.4'
  VERSION='12.4'
elif [ $VERSION == 2 ]; then
  echo Note: VERSION='11.8'
  VERSION='11.8'
fi
