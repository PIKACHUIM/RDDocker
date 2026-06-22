#!/bin/bash

source Scripts/Titles.sh
echo "   ============================Available Version==========================="
echo "      [1] 3.24.1 (Branch date End: 2025-05-22 || of support: 2027-05-01)  "
echo "      [2] 3.23.4 (Branch date End: 2024-11-22 || of support: 2026-11-01)  "
echo "   ========================================================================"
echo
echo -n "   Choice System Version Number(1): "
read VERSION
if [ ! $VERSION ]; then
  echo Note: VERSION='[1] 3.24.1'
  VERNAME='3.24.1'
  VERSION='32401'
elif [ $VERSION == 1 ]; then
  VERNAME='3.24.1'
  VERSION='32401'
elif [ $VERSION == 2 ]; then
  VERNAME='3.23.4'
  VERSION='32304'
fi
