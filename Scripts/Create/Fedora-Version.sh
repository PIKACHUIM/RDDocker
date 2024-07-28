#!/bin/bash
clear
echo
echo "   ============================Available Version==========================="
echo "      [1] Fedora Linux 40 (Release at 2024-04-23  Maintained for 13 months)"
echo "   ========================================================================"
echo
echo -n "   Choice System Version Number(1): "
read VERSION
if [ ! $VERSION ]; then
  echo Note: VERSION='[1] Fedora Linux 40'
  VERSION=1
fi
if [ $VERSION == 1 ]; then
  VERNAME='40'
  VERSION='40'
fi
