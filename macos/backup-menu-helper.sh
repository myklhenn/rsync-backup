#!/bin/sh
#
# This script, intended for use in conjunction with the "backup-menu" BitBar
# script, utilizes the config variables (loaded from $HOME/.backup-config)
# described below to facilitate checking backup log files and starting,
# stopping, and pausing backups for the configured client and server.
#
# The "--view-log" option establishes an SSH connection and shows the most
# recent contents of the configured repository's log file.
#
# The "--hide-error" option removes the $HOME/.backup-error file (if present)
# to remove error messages displayed in "backup-menu".
#
# The "--start-backup" option establishes an SSH connection and executes the
# configured repository's backup script.
#
# The "--stop-backup" option stops the process of a currently running backup.
#
# The "--pause-backups" option adds or removes a $HOME/.backup-paused file to
# facilitate the pausing of backups.
#
# Expected config variables (loaded from $HOME/.backup-config):
#
# BACKUP_SERVER_HOSTNAME -- hostname of backup server (as used in ssh config)
# BACKUP_REPO_PATH -- path on server of backup repository
# BACKUP_SSH_KEY_PATH -- local path of private SSH key used to connect to server

use_colors() {
    RC="\033[0;31m" # red color
    GC="\033[0;32m" # green color
    YC="\033[0;33m" # yellow color
    NC="\033[0m"    # no color
}
[ "$SHELL" != "/bin/csh" ] && use_colors

print_usage() {
    # ($1: name of command)
    echo "Usage: $(basename $1) --OPTION"
    echo "  --view-log"
    echo "  --hide-error"
    echo "  --start-backup"
    echo "  --stop-backup"
    echo "  --pause-backups"
}
check_config_item() {
    # ($1: config item to check $2: name of config item)
    if [ -z "$1" ]; then
        echo $YC"Required parameter \"$2\" missing from configuration."$NC
        ERRORS=1
    fi
}
check_ssh_key() {
    check_config_item $BACKUP_SSH_KEY_PATH "BACKUP_SSH_KEY_PATH"
    if ! ssh-add -L | grep "$(cat $BACKUP_SSH_KEY_PATH.pub)" >/dev/null; then
        echo $YC"Adding your server's SSH key to your agent first..."$NC
        ssh-add $BACKUP_SSH_KEY_PATH
    fi
}
abort() {
    echo $RC"Aborting command."$NC
    exit 1
}
refresh_menu() {
    open -g "bitbar://refreshPlugin?name=backup-menu.*?.sh"
}

[ -e $HOME/.backup-config ] && source $HOME/.backup-config

case $1 in
"--view-log")
    check_ssh_key
    check_config_item $BACKUP_SERVER_HOSTNAME "BACKUP_SERVER_HOSTNAME"
    check_config_item $BACKUP_REPO_PATH "BACKUP_REPO_PATH"
    [ "$ERRORS" = "1" ] && abort
    ssh $BACKUP_SERVER_HOSTNAME "tail -fn 24 $BACKUP_REPO_PATH/backup-log"
    ;;
"--hide-error")
    rm -f $HOME/.backup-error
    refresh_menu
    ;;
"--start-backup")
    check_ssh_key
    check_config_item $BACKUP_SERVER_HOSTNAME "BACKUP_SERVER_HOSTNAME"
    check_config_item $BACKUP_REPO_PATH "BACKUP_REPO_PATH"
    [ "$ERRORS" = "1" ] && abort
    ssh $BACKUP_SERVER_HOSTNAME "$BACKUP_REPO_PATH/backup-script" --dry-run
    ;;
"--stop-backup")
    pkill -4 -af ".backup-suite/common/backup-client-script.sh"
    ;;
"--pause-backups")
    rm $HOME/.backup-paused 2>/dev/null || touch $HOME/.backup-paused
    refresh_menu
    ;;
"--help")
    print_usage
    ;;
*)
    echo "Valid command not specified!"
    print_usage
    exit 1
    ;;
esac
