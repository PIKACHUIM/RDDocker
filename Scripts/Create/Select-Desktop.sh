#!/bin/bash
source Scripts/Titles.sh
# Choose Desktop -------------------------------------------------------------------
echo "   ============================Available Desktop==========================="
echo "      [1] Servers No Desktop [ √ SSH / × GUI APPs / × NoMachine / × VNC ]  "
echo "      [2] Desktop CuteFishDE [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
#echo "      [3] Desktop KDE Plasma [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
#echo "      [4] Desktop GNOME Base [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
#echo "      [5] Desktop Deepin DDE [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
echo "      [6] Desktop OpenBox DE [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
echo "      [7] Desktop Xfce4 Lite [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
echo "      [8] Desktop LingmoOSDE [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
echo "      [0] X11 UI Environment [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
echo "   ========================================================================"
echo
echo -n "   Choose GUI Environments Type(1): "
read GUI_ENV
if [ ! $GUI_ENV ]; then
  echo "   Note: GUI_ENV=[1] Servers"
  GUI_ENV=1
fi
if [ $GUI_ENV == 1 ]; then
  GUI_ENV=server
  DC_FILE=Base
elif [ $GUI_ENV == 2 ]; then
  GUI_ENV=cuteos
  DC_FILE=CuteFishDE
elif [ $GUI_ENV == 3 ]; then
  GUI_ENV=plasma
  DC_FILE=KDE
elif [ $GUI_ENV == 4 ]; then
  GUI_ENV=gnome3
  DC_FILE=GNOME
elif [ $GUI_ENV == 5 ]; then
  GUI_ENV=deepin
  DC_FILE=DDE
elif [ $GUI_ENV == 6 ]; then
  GUI_ENV=op_box
  DC_FILE=OpenBox
elif [ $GUI_ENV == 7 ]; then
  GUI_ENV=xfce_4
  DC_FILE=Xfce4
elif [ $GUI_ENV == 8 ]; then
  GUI_ENV=lingmo
  DC_FILE=Lingmo
elif [ $GUI_ENV == 0 ]; then
  GUI_ENV=x11gui
  DC_FILE=Desktop
fi
