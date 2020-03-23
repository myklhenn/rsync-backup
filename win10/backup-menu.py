#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""rsync-checker: This script creates an entry in Windows' system tray, spawns
a thread that frequently checks if an instance of rsync is running, and updates
the icon and text used in the system tray accordingly.
"""

import os
import sys
import time
import threading

from subprocess import getstatusoutput
from infi.systray import SysTrayIcon

current_dir = os.path.dirname(os.path.realpath(__file__)) + '\\'

### CONFIG ###

idle_icon = current_dir + 'check-circle.ico'
idle_text = 'rsync is not running'

syncing_icon = current_dir + 'arrow-circle-up.ico'
syncing_text = 'rsync is running'

# (delays are in seconds)
check_delay = 5
start_delay = 1

##############


def rsync_checker(systray_icon):
  while True:
    cmd_status, cmd_output = getstatusoutput('tasklist | find /c /i "rsync"')

    # TODO: check registry to see if system theme is light or dark, and apply appropriate icon

    if cmd_output == '0':
      systray_icon.update(icon=idle_icon, hover_text=idle_text)
    else:
      systray_icon.update(icon=syncing_icon, hover_text=syncing_text)
    time.sleep(check_delay)


systray_icon = SysTrayIcon(idle_icon, idle_text)
systray_icon.start()

rsync_checker_thread = threading.Timer(
    start_delay, rsync_checker, args=[systray_icon])
rsync_checker_thread.daemon = True
rsync_checker_thread.start()
