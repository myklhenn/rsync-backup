#!/bin/sh

# TODO: find a way to "respond" if backups is paused or cancelled by user

refresh_menu() {
    open -g "bitbar://refreshPlugin?name=backup-menu.*?.sh"
}
cleanup() {
    pkill -1 -af "rsync --server --sender"
    rm -f $HOME/.backup-running
    refresh_menu
}
trap cleanup 0 1 4

[ -e $HOME/.backup-paused ] && exit 1

echo "$(date "+%I:%M %p")" >$HOME/.backup-running

refresh_menu
rsync $@

if [ $? = 0 ]; then
    rm -f $HOME/.backup-error
    echo "$(date "+%a %m/%d/%Y %I:%M %p")" >$HOME/.backup-success
else
    echo "$(date "+%a %m/%d/%Y %I:%M %p")" >$HOME/.backup-error
fi
exit 0
