#!/bin/sh
# TODO: find a way to "respond" if backups is paused or cancelled by user

cleanup () {
  rm -f $HOME/.backup-running
}
trap cleanup 0 1 2 3 6

[ -e $HOME/.backup-paused ] && exit 1

echo "$(date "+%I:%M %p")" > $HOME/.backup-running

rsync $@

if [ $? = 0 ]; then
  rm -f $HOME/.backup-error
  echo "$(date "+%a %d/%m/%Y %I:%M %p")" > $HOME/.backup-success
else
  echo "$(date "+%a %d/%m/%Y %I:%M %p")" > $HOME/.backup-error
fi