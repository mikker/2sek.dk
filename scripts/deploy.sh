#!/bin/sh -x
DIR="/var/www/apps/2sek.dk"
UPDATE="git pull"
BUNDLE="zsh --login -c 'bundle --deployment'"
RESTART="touch tmp/restart.txt"
ssh brnbw.com "cd $DIR && $UPDATE && $BUNDLE && $RESTART"
