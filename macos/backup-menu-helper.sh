#!/bin/bash

# This script, intended for use in conjunction with the "backup-menu" BitBar
# script, utilizes the config variables (loaded from $HOME/.backup-config)
# described below to facilitate checking backup log files and starting,
# stopping, and pausing backups for the configured client and server.
#
# The --view-log option establishes an SSH connection and shows the most recent
# contents of the configured repository's log file.
#
# The --hide-error option removes the $HOME/.backup-error file (if present)
# to remove error messages displayed in "backup-menu".
#
# The --start-backup option establishes an SSH connection and executes the
# configured repository's backup script.
#
# The --stop-backup option stops the process of a currently running backup.
#
# The --pause-backups option adds or removes a $HOME/.backup-paused file to
# facilitate the pausing of backups.
#
# Expected config variables (loaded from $HOME/.backup-config):
#
# BACKUP_SERVER_HOSTNAME -- hostname of backup server (as used in ssh config)
# BACKUP_REPO_PATH -- path on server of backup repository
# BACKUP_SSH_KEY_PATH -- local path of private SSH key used to connect to server

check_ssh_key () {
  if ! ssh-add -L | grep "$(cat $BACKUP_SSH_KEY_PATH.pub)" > /dev/null; then
    echo "Adding your server's SSH key to your agent first..."
    ssh-add $BACKUP_SSH_KEY_PATH
  fi
}
refresh_menu () {
  open -g "bitbar://refreshPlugin?name=backup-menu.*?.sh"
}

[ -e $HOME/.backup-config ] && source $HOME/.backup-config

case $1 in
  "--view-log")
    check_ssh_key
    ssh $BACKUP_SERVER_HOSTNAME "tail -fn 24 $BACKUP_REPO_PATH/backup-log"
    ;;
  "--hide-error")
    rm -f $HOME/.backup-error
    refresh_menu
    ;;
  "--start-backup")
    check_ssh_key
    ssh $BACKUP_SERVER_HOSTNAME "$BACKUP_REPO_PATH/backup-script"
    ;;
  "--stop-backup")
    pkill -15 -af "/bin/sh /Users/myklhenn/.backup-script"
    ;;
  "--pause-backups")
    rm $HOME/.backup-paused 2>/dev/null || touch $HOME/.backup-paused
    refresh_menu
    ;;
  *)
    SCRIPT_NAME=$(basename $0)
    echo "No command specified!"
    echo "Usage: $SCRIPT_NAME --OPTION"
    echo "  --view-log"
    echo "  --hide-error"
    echo "  --start-backup"
    echo "  --stop-backup"
    echo "  --pause-backups"
    exit 1
    ;;
esac
