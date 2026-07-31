#!/bin/bash
#
# Copyright (C) 2023 Ultimaker B.V.
#
# Description: This script looks for which input event refers to the touch screen and starts
# a Framebuffer VNC server passing that input event as argument
#

set -eu

TOUCHSCREEN_ADDR_EDT="0038"
TOUCHSCREEN_ADDR_GOODIX="005d"
TOUCH_EVENT=""

for EVENT_PATH in /sys/class/input/event*; do
  if readlink "${EVENT_PATH}" | grep -qE "${TOUCHSCREEN_ADDR_EDT}|${TOUCHSCREEN_ADDR_GOODIX}"; then
    TOUCH_EVENT="${EVENT_PATH##*/event}"
  fi
done

touchscreen_input="/dev/input/event${TOUCH_EVENT}"

if [ ! -c "${touchscreen_input}" ]; then
  echo "Could not find touchscreen device..."
  exit 1
fi;

echo "Starting framebuffer vnc server..."
/usr/bin/framebuffer-vncserver -t "${touchscreen_input}"
