#!/bin/bash

source Scripts/Titles.sh
echo "   ============================Available Version==========================="
echo "      [1] 3.21.03 (Branch date End: 2024-12-05 || of support: 2026-11-01)  "
echo "      [2] 3.20.06 (Branch date End: 2024-05-22 || of support: 2026-04-01)  "
echo "   ========================================================================"
echo
echo -n "   Choice System Version Number(1): "
read VERSION
if [ ! $VERSION ]; then
  echo Note: VERSION='[1] 3.21.03'
  VERNAME='3.21.3'
  VERSION='32103'
elif [ $VERSION == 1 ]; then
  VERNAME='3.21.3'
  VERSION='32103'
elif [ $VERSION == 2 ]; then
  VERNAME='3.20.6'
  VERSION='32006'
fi