#!/bin/bash

# <bitbar.title>Backup Menu</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Michael Henning</bitbar.author>
# <bitbar.author.github>myklhenn</bitbar.author.github>
# <bitbar.desc>A BitBar plugin that integrates with rsync-backup</bitbar.desc>
# <bitbar.image>https://raw.githubusercontent.com/myklhenn/rsync-backup/master/img/rsync-not-running-and-running.png</bitbar.image>
# <bitbar.abouturl>https://github.com/myklhenn/rsync-backup</bitbar.abouturl>
#
# Optional config variables (loaded from $HOME/.backup-config):
#
# BACKUP_REPO_PATH -- path on server of backup repository
# BACKUP_TERM_COMMAND -- path to launcher for alternative terminal (i.e. iTerm)

[ -e $HOME/.backup-config ] && source $HOME/.backup-config

HELPER_CMD=""
IMG_PATH=""

export PATH=$PATH:/usr/local/bin
if which realpath > /dev/null; then
  REPO_PATH="$(dirname $(realpath $0))/.."
  HELPER_CMD="$REPO_PATH/macos/backup-menu-helper.sh"
  IMG_PATH="$REPO_PATH/img"
else
  echo "⚠️"
  echo "---"
  echo "This BitBar plugin requires the"
  echo "\"realpath\" command to function"
  echo -n "Install with Brew | "
  if [ -e $BACKUP_TERM_COMMAND ]; then
    echo "bash=$BACKUP_TERM_COMMAND param1=\"brew install coreutils\" terminal=false"
  else
    echo "bash=brew param1=install param2=coreutils terminal=true"
  fi
  echo "Learn More | href=https://github.com/myklhenn/rsync-backup/blob/master/README.md"
  exit 1
fi

if [ -e $HOME/.backup-running ]; then
  echo "| templateImage=$(<$IMG_PATH/fa-arrow-circle-up-solid)"
  echo "---"
  echo "Backup running"
  echo "(started at $(<$HOME/.backup-running))"
  echo "---"
  echo "Stop Backup | bash=$HELPER_CMD param1=\"--stop-backup\" terminal=false"
else
  if [ -e $HOME/.backup-paused ]; then
    echo "| templateImage=$(<$IMG_PATH/fa-pause-circle)"
    echo "---"
    echo "Backups are paused"
    echo "---"
  elif [ -e $HOME/.backup-error ]; then
    echo "| templateImage=$(<$IMG_PATH/fa-times-circle-solid)"
    echo "---"
    echo "There was an error during the last backup"
    echo "(on $(<$HOME/.backup-error))"
    echo "Hide Error | bash=$HELPER_CMD param1=\"--hide-error\" terminal=false"
    echo "---"
  else
    echo "| templateImage=$(<$IMG_PATH/fa-check-circle)"
    echo "---"
    echo "Backup not running"
    echo "---"
  fi
  if [ -e $HOME/.backup-success ]; then
    echo "Last successful backup on"
    echo "$(<$HOME/.backup-success)"
    echo "---"
  fi
  if [ -n "$BACKUP_REPO_PATH" ] && [ -e $HELPER_CMD ]; then
    echo -n "Start Backup | "
    if [ -e $BACKUP_TERM_COMMAND ]; then
      echo "bash=$BACKUP_TERM_COMMAND param1=\"$HELPER_CMD --start-backup\" terminal=false"
    else
      echo "bash=$HELPER_CMD param1=\"--start-backup\" terminal=true"
    fi
  fi
fi
if [ -e $HOME/.backup-paused ]; then
    echo -n "Resume Backups | "
else
  echo -n "Pause Backups | "
fi
echo "bash=$HELPER_CMD param1=\"--pause-backups\" terminal=false"
if [ -n "$BACKUP_REPO_PATH" ] && [ -e $HELPER_CMD ]; then
  echo -n "Backup Log | "
  if [ -e $BACKUP_TERM_COMMAND ]; then
    echo "bash=$BACKUP_TERM_COMMAND param1=\"$HELPER_CMD --view-log\" terminal=false"
  else
    echo "bash=$HELPER_CMD param1=\"--view-log\" terminal=true"
  fi
fi