#!/bin/bash
export DISPLAY=:1
echo "x11vnc  -forever -noxdamage -repeat -rfbauth /etc/x11vnc.pass -rfbport 5900 -shared -create -display :1 &"
nohup x11vnc  -forever -noxdamage -repeat -rfbauth /etc/x11vnc.pass -rfbport 5900 -shared -create -display :1 &

