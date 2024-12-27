#!/bin/bash
export DISPLAY=:9
nohup x11vnc -forever -noxdamage -repeat -rfbauth /etc/x11vnc.pass -rfbport 5900 -shared -create -display :9 &

