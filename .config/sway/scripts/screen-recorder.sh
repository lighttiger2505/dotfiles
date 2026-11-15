#!/bin/sh
# vim: ft=sh

pid=`pgrep wf-recorder`
status=$?

if [ $status != 0 ] 
then 
  wf-recorder -f ${HOME}/screencapture/mv-$(date +%s).mp4 -g "$(slurp)";
else 
  pkill --signal SIGINT wf-recorder
fi;
