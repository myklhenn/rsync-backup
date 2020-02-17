#!/bin/sh

use_colors() {
    RC="\033[0;31m" # red color
    GC="\033[0;32m" # green color
    YC="\033[0;33m" # yellow color
    NC="\033[0m"    # no color
}
[ "$SHELL" != "/bin/csh" ] && use_colors

check_config_item() {
    # ($1: config item to check $2: name of config item)
    if [ -z "$1" ]; then
        echo $YC"Required parameter \"$2\" missing from configuration."$NC
        ERRORS=1
    fi
}
abort() {
    echo $RC"Aborting backup."$NC
    exit 1
}

REPO_PATH=$(dirname $0)

if [ -e $REPO_PATH/backup-config ]; then
    source $REPO_PATH/backup-config
else
    echo $YC"Backup configuration not found where expected."$NC
    echo $YC"Ensure you are running this script from a link located inside"$NC
    echo $YC"a backup repository."$NC
    abort
fi

check_config_item "$BACKUP_CLIENT_HOSTNAME" "BACKUP_CLIENT_HOSTNAME"
check_config_item "$BACKUP_CLIENT_PATH" "BACKUP_CLIENT_PATH"
check_config_item "$BACKUP_DEST_FOLDER" "BACKUP_DEST_FOLDER"

[ "$ERRORS" = "1" ] && abort

echo $GC"Starting backup."$NC

/usr/local/bin/rsync $@ \
    --verbose \
    --itemize-changes \
    --stats \
    --archive \
    --delete \
    --delay-updates \
    --rsh="/usr/bin/ssh" \
    --rsync-path="~/.backup-suite/common/backup-client-script.sh" \
    --include-from="$REPO_PATH/backup-filter" \
    --log-file="$REPO_PATH/backup-log" \
    $BACKUP_CLIENT_HOSTNAME:$BACKUP_CLIENT_PATH \
    $REPO_PATH/$BACKUP_DEST_FOLDER

if [ $? != 0 ]; then
    echo $RC"Done, but with errors.\n"$NC
else
    echo $GC"Done.\n"$NC
fi
