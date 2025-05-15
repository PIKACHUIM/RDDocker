#!/bin/bash
source Scripts/Titles.sh
# Choose Desktop -------------------------------------------------------------------

case $OS_TYPE in
    "ubuntu"|"debian"|"archos"|"fedora"|"alpine")
        echo "   ============================Available Desktop==========================="
        echo "      [1] Servers NoGraphic  [ √ SSH / × GUI APPs / × NoMachine / × VNC ]  "
        ;&
    "ubuntu"|"debian"|"archos"|"fedora"|"alpine")
        echo "      [2] Desktop Lingmo DE  [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
        ;&
    "ubuntu"|"debian"|"archos"|"fedora"|"alpine")
        echo "      [3] Desktop Gnome3 DE  [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
        ;&
    "ubuntu"|"debian"|"archos"|"fedora"|"alpine")
        echo "      [4] Desktop Xfce4L DE  [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
        ;&
    "ubuntu"|"debian")
        echo "      [5] Desktop Deepin DE  [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
        ;&
    "ubuntu"|"debian"|"archos"|"fedora"|"alpine")
        echo "      [6] Desktop Plasma DE  [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
        ;&
    "ubuntu"|"debian"|"archos"|"fedora"|"alpine")
        #echo "      [6] Desktop Icewm Lite [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
        #echo "      [7] Desktop ********** [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
        #echo "      [8] Desktop ********** [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
        #echo "      [9] Desktop CuteFishDE [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
        echo "      [0] X11 GUI Basic ENV  [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
        echo "   ========================================================================"
        ;;
esac
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
elif [ $GUI_ENV == 5 ]; then
  GUI_ENV=deepin
  DC_FILE=Deepin
elif [ $GUI_ENV == 6 ]; then
  GUI_ENV=plasma
  DC_FILE=Plasma
elif [ $GUI_ENV == 9 ]; then
  GUI_ENV=cuteos
  DC_FILE=CuteOS
elif [ $GUI_ENV == 0 ]; then
  GUI_ENV=x11gui
  DC_FILE=X11GUI
fi
