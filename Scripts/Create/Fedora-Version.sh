#!/bin/bash

source Scripts/Titles.sh
echo "   ============================Available Version==========================="
echo "      [1] Fedora Linux 42 (Release at 2025-04-16 Maintained for 13 months)"
echo "      [2] Fedora Linux 41 (Release at 2024-10-30 Maintained for 13 months)"
echo "   ========================================================================"
echo
echo -n "   Choice System Version Number(1): "
read VERSION
if [ ! $VERSION ]; then
  echo Note: VERSION='[1] Fedora Linux 40'
  VERNAME='42'
  VERSION='42.00'
fi
if [ $VERSION == 1 ]; then
  VERNAME='42'
  VERSION='42.00'
fi
if [ $VERSION == 2 ]; then
  VERNAME='41'
  VERSION='41.00'
fi
