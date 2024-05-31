#!/bin/bash
source Scripts/Titles.sh
# GPU List ------------------------------------------------------------------------
echo "   =============================Graphics Cards============================="
echo "      [A] All Graphics Cards [Using All Graphics of Current Local Syatem]  "
echo "      [N] Disabled All Cards [Don't Use Graphics of Current Local Syatem]  "
echo "   ========================================================================"
echo -n "   Choose Graphics Cards Enable(N): "
read GPU_LIST
if [ ! $GPU_LIST ]; then
  echo "   Note: GPU_LIST=[N] Disabled All Cards"
  GPU_LIST=""
fi
if [ $GPU_LIST == A ]; then
  GPU_LIST=" --gpus all -e NVIDIA_DRIVER_CAPABILITIES=compute,utility -e NVIDIA_VISIBLE_DEVICES=all"
elif [ $GPU_LIST == N ]; then
  GPU_LIST=""
fi
