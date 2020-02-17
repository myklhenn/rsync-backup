#!/bin/bash
#
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

SUITE_PATH="$HOME/.backup-suite"

if [ ! -e $SUITE_PATH ]; then
    echo "⚠️"
    echo "---"
    echo "Backup suite is not present in home directory, as required."
    echo "Use the suite's \"install-macos\" command to resolve this issue."
    exit 1
fi

HELPER_CMD="$SUITE_PATH/macos/backup-menu-helper.sh"

echo_menu_item_with_term() {
    # ($1: name of command to show in BitBar, $2: argument for helper script)
    echo -n "$1 | bash="
    if [ -e $BACKUP_TERM_COMMAND ]; then
        echo "$BACKUP_TERM_COMMAND param1=\"$HELPER_CMD $2\" terminal=false"
    else
        echo "$HELPER_CMD param1=\"$2\" terminal=true"
    fi
}
echo_menu_item() {
    # ($1: name of command to show in BitBar, $2: argument for helper script)
    echo "$1 | bash=$HELPER_CMD param1=\"$2\" terminal=false"
}
echo_menu_icon() {
    # ($1: name of file in $SUITE_PATH/img containing a base64-encoded icon)
    echo "| templateImage=$(<$SUITE_PATH/img/$1)"
}

[ -e $HOME/.backup-config ] && source $HOME/.backup-config

if [ -e $HOME/.backup-running ]; then
    echo_menu_icon "fa-arrow-circle-up-solid"
    echo "---"
    echo "Backup running"
    echo "(started at $(<$HOME/.backup-running))"
    echo "---"
    echo_menu_item "Stop Backup" "--stop-backup"
else
    if [ -e $HOME/.backup-paused ]; then
        echo_menu_icon "fa-pause-circle"
        echo "---"
        echo "Backups are paused"
        echo "---"
    elif [ -e $HOME/.backup-error ]; then
        echo_menu_icon "fa-times-circle-solid"
        echo "---"
        echo "There was an error during the last backup"
        echo "(on $(<$HOME/.backup-error))"
        echo_menu_item "Hide Error" "--hide-error"
        echo "---"
    else
        echo_menu_icon "fa-check-circle"
        echo "---"
        echo "Backup not running"
        echo "---"
    fi
    if [ -e $HOME/.backup-success ]; then
        echo "Last successful backup on"
        echo "$(<$HOME/.backup-success)"
        echo "---"
    fi
    if [ -n "$BACKUP_REPO_PATH" ] && [ ! -e $HOME/.backup-paused ]; then
        echo_menu_item_with_term "Start Backup" "--start-backup"
    fi
fi
if [ -e $HOME/.backup-paused ]; then
    echo_menu_item "Resume Backups" "--pause-backups"
else
    echo_menu_item "Pause Backups" "--pause-backups"
fi
if [ -n "$BACKUP_REPO_PATH" ]; then
    echo_menu_item_with_term "Backup Log" "--view-log"
fi
