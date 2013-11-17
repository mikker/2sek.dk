#!/bin/sh -x
DIR="w/apps/2sek.dk/current"
UPDATE="git pull"
BUNDLE="zsh --login -c 'bundle --deployment'"
RESTART="touch tmp/restart.txt"
ssh brnbw.com "cd $DIR && $UPDATE && $BUNDLE && $RESTART"
