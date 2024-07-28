#!/bin/bash
clear
echo
echo "   ============================Available Version==========================="
echo "      [1] Latest (In ArchLinux, you can NOT choose a version yourself!!)"
echo "   ========================================================================"
echo
echo -n "   Choice System Version Number(1): "
read VERSION
if [ ! $VERSION ]; then
  echo Note: VERSION='[1] Latest'
  VERNAME='latest'
  VERSION='latest'
elif [ $VERSION == 1 ]; then
  echo Note: VERSION='latest'
  VERNAME='latest'
  VERSION='latest'
fi
