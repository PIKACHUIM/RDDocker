#!/bin/bash
source scripts/manager/titles.sh
# Choose desktop -------------------------------------------------------------------
echo "   ============================Available Desktop==========================="
case "$OS_TYPE" in
    "ubuntu"|"debian"|"archos"|"fedora"|"alpine")
        echo "      [1] Servers NoGraphic  [ √ SSH / × GUI APPs / × NoMachine / × VNC ]  "
        ;;
esac

case "$OS_TYPE" in
    "ubuntu"|"debian"|"archos")
        echo "      [2] Desktop Lingmo DE  [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
        ;;
esac

case "$OS_TYPE" in
    "ubuntu"|"debian"|"archos"|"fedora"|"alpine")
        echo "      [3] Desktop Gnome3 DE  [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
        ;;
esac

case "$OS_TYPE" in
    "ubuntu"|"debian"|"archos"|"fedora"|"alpine")
        echo "      [4] Desktop Xfce4L DE  [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
        ;;
esac

case "$OS_TYPE" in
    "debian")
        echo "      [5] Desktop Deepin DE  [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
        ;;
esac

case "$OS_TYPE" in
    "ubuntu"|"debian"|"archos"|"fedora"|"alpine")
        echo "      [6] Desktop Plasma DE  [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
        ;;
esac

case "$OS_TYPE" in
    "ubuntu"|"debian"|"archos"|"fedora"|"alpine")
        echo "      [0] X11 GUI Basic ENV  [ √ SSH / √ GUI APPs / √ NoMachine / √ VNC ]  "
        ;;
esac
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
  DC_FILE=server
elif [ $GUI_ENV == 2 ]; then
  GUI_ENV=lingmo
  DC_FILE=lingmo
elif [ $GUI_ENV == 3 ]; then
  GUI_ENV=gnome3
  DC_FILE=gnome3
elif [ $GUI_ENV == 4 ]; then
  GUI_ENV=xfce4l
  DC_FILE=xfce4l
elif [ $GUI_ENV == 5 ]; then
  GUI_ENV=deepin
  DC_FILE=deepin
elif [ $GUI_ENV == 6 ]; then
  GUI_ENV=plasma
  DC_FILE=plasma
elif [ $GUI_ENV == 0 ]; then
  GUI_ENV=x11gui
  DC_FILE=x11gui
fi
