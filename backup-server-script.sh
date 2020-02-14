#!/bin/sh

missing_parameter () {
    echo "Required parameter \"$1\" missing from configuration."
    echo "Aborting backup."
    exit 1
}

REPO_PATH=$(dirname $0)

if [ -e $REPO_PATH/backup-config ]; then
    source $REPO_PATH/backup-config
else
    echo "Backup configuration not found where expected."
    echo "Ensure you are running this script as linked from inside a backup"
    echo "repository, and using the full path of the link."
    exit 1
fi
if [ -z "$BACKUP_CLIENT_HOSTNAME" ]; then
    missing_parameter "BACKUP_CLIENT_HOSTNAME"
elif [ -z "$BACKUP_CLIENT_PATH" ]; then
    missing_parameter "BACKUP_CLIENT_PATH"
elif [ -z "$BACKUP_CLIENT_SCRIPT" ]; then
    missing_parameter "BACKUP_CLIENT_SCRIPT"
fi

/usr/local/bin/rsync $@ \
    --verbose \
    --itemize-changes \
    --stats \
    --archive \
    --delete \
    --delay-updates \
    --rsh="/usr/bin/ssh" \
    --rsync-path="$BACKUP_CLIENT_SCRIPT" \
    --include-from="$REPO_PATH/backup-filter" \
    --log-file="$REPO_PATH/backup-log" \
    $BACKUP_CLIENT_HOSTNAME:$BACKUP_CLIENT_PATH \
    $REPO_PATH/$BACKUP_DEST_FOLDER