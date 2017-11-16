#!/bin/sh

xset -dpms     # disable DPMS (Energy Star) features.
xset s off       # disable screen saver
xset s noblank # don't blank the video device

startx &

export DISPLAY=:0
midori -e Fullscreen -a file:///home/pi/rpi_side_by_side.html &

cd /home/pi/rpi-ibeacon/src/
export SMART_SCAVENGER_HUNT_BEACON_MODE=depot
python main.py
