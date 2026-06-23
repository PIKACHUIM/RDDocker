#!/bin/bash

source scripts/manager/titles.sh
echo "   ============================Available Version==========================="
echo "      [1] Fedora Linux 44 (Release at 2026-04 Maintained for 13 months)"
echo "      [2] Fedora Linux 43 (Release at 2025-11 Maintained for 13 months)"
echo "   ========================================================================"
echo
echo -n "   Choice System Version Number(1): "
read VERSION
if [ ! $VERSION ]; then
  echo Note: VERSION='[1] Fedora Linux 44'
  VERNAME='44'
  VERSION='44.00'
fi
if [ $VERSION == 1 ]; then
  VERNAME='44'
  VERSION='44.00'
fi
if [ $VERSION == 2 ]; then
  VERNAME='43'
  VERSION='43.00'
fi
