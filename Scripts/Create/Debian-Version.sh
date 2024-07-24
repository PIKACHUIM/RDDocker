#!/bin/bash

source Scripts/Titles.sh
echo "   ============================Available Version==========================="
echo "      [1] Debian 13 Trixie     [ √ Now Recommend / Support Until 2028 ]    "
echo "      [2] Debian 12 bookworm   [ √ Now Recommend / Support Until 2028 ]    "
echo "      [3] Debian 11 Bullseye   [ × Not Recommend / Support Until 2025 ]    "
echo "   ========================================================================"
echo
echo -n "   Choice System Version Number(1): "
read VERSION
if [ ! $VERSION ]; then
  VERSION=1
fi
if [ $VERSION == 1 ]; then
  echo "   Note: VERSION= Debian 13(Trixie)"
  echo "   Note: This is a testing version!"
  sleep 1
  VERNAME='trixie'
  VERSION="13"
elif [ $VERSION == 2 ]; then
  echo "   Note: VERSION=Debian 12 bookworm"
  VERNAME='bookworm'
  VERSION="12"
elif [ $VERSION == 3 ]; then
  echo "   Note: VERSION=Debian 11 Bullseye"
  VERNAME='bullseye'
  VERSION="11"
fi
