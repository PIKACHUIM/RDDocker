#!/bin/bash

source Scripts/Titles.sh
echo "   ============================Available Version==========================="
echo "      [1] Devel (In Arch Linux, you can only choose the latest version now)"
echo "   ========================================================================"
echo
echo -n "   Choice System Version Number(1): "
read VERSION
if [ ! $VERSION ]; then
  echo Note: VERSION='[1] Latest'
  VERNAME='latest'
  VERSION='devel'
elif [ $VERSION == 1 ]; then
  echo Note: VERSION='devel'
  VERNAME='latest'
  VERSION='devel'
fi
