#!/bin/bash
#
# Author: Vincenzo D'Amore v.damore@gmail.com
# 20/11/2014
#

function shutdown()
{
	echo `date` " " `whoami` " Received a signal to shutdown"
	osascript -e "set Volume 0"
	touch /Users/Philipp/Desktop/shutdown
	id > /Users/Philipp/Desktop/shutdown
	exit 0
}

function startup()
{
	echo `date` " " `whoami` " Starting..."
	tail -f /dev/null &
	wait $!
}

trap shutdown SIGTERM
trap shutdown SIGKILL

startup;

