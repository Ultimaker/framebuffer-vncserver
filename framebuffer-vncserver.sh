#!/bin/bash
#
# Copyright (C) 2023 Ultimaker B.V.
#
# Description: This script looks for which input event refers to the touch screen and starts
# a Framebuffer VNC server passing that input event as argument
#

set -eu

TOUCHSCREEN_ADDR="0038"
TOUCH_EVENT=""

for EVENT in {0..5}; do
  if readlink "/sys/class/input/event${EVENT}" | grep -q -e "[0-5]-${TOUCHSCREEN_ADDR}"; then
    TOUCH_EVENT="${EVENT}";
  fi;
done;

touchscreen_input="/dev/input/event${TOUCH_EVENT}"

if [ ! -c "${touchscreen_input}" ]; then
  echo "Could not find touchscreen device..."
  exit 1
fi;

echo "Starting framebuffer vnc server..."
/usr/bin/framebuffer-vncserver -t "${touchscreen_input}"
