#!/bin/bash
source Scripts/Titles.sh
# Choose Desktop -------------------------------------------------------------------
echo "   ============================Available Desktop==========================="
echo "      [1] Servers NoGraphic  [ √ SSH / × GUI APPs / × NoMachine / × VNC ]  "
echo "      [2] Desktop Lingmo DE  [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
echo "      [3] Desktop Gnome GUI  [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
echo "      [4] Desktop Xfce4 GUI  [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
echo "      [0] X11 GUI Basic ENV  [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
#echo "      [5] Desktop Deepin DDE [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
#echo "      [6] Desktop CuteFishDE [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
#echo "      [7] Desktop KDE Plasma [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
#echo "      [8] Desktop Xfwm4 Lite [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
#echo "      [9] Desktop Icewm Lite [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
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
  DC_FILE=Server
elif [ $GUI_ENV == 2 ]; then
  GUI_ENV=lingmo
  DC_FILE=Lingmo
elif [ $GUI_ENV == 3 ]; then
  GUI_ENV=gnome3
  DC_FILE=GNOME3
elif [ $GUI_ENV == 4 ]; then
  GUI_ENV=xfce4l
  DC_FILE=Xfce4L
elif [ $GUI_ENV == 0 ]; then
  GUI_ENV=x11gui
  DC_FILE=X11GUI
fi
