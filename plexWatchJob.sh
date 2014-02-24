#!/bin/bash
#
# (C) Patrik Kernstock
#  Website: pkern.at
#
# Version....: 1.0
# Date.......: 24.02.2014
# Licence....: CC BY-SA 4.0 (https://creativecommons.org/licenses/by-sa/4.0/deed.en)
#
# Description: 
#   This is just a simple script which executes the plexWatch script every 30 seconds 
#   (by default, easily changeable with the SLEEPTIME variable). Crontab is only able
#   to execute scripts every minute, so I decided to write a simple bash script for it.
#
#   The script is executing plexWatch after sleeping for the defined seconds, until
#   you remove the PIDFILE (which is also defined in the script). Even if you start the
#   bash script multiple times, it's only running once (because it checks the proccess id).
#
# Changelog:
#   v1.0.0: First version
#
# ATTENTION!
#   Please make sure that plexWatch is working without issues
#   first, before you are continuing using this simple script.
#
# Download the script using:
#   wget -O /opt/plexWatch/plexWatchJob.sh https://raw.github.com/patschi/linux-bash-scripts/master/plexWatchJob.sh
#
# Start the script manually using:
#   bash /opt/plexWatch/plexWatchJob.sh &>/dev/null &
#
# ...or add this line to crontab (crontab -e) to automate it:
#   * * * * * bash /opt/plexWatch/plexWatchJob.sh &>/dev/null &
#
SLEEPTIME="30"
PIDFILE="/tmp/plexWatchJob.pid"

if [ -f "$PIDFILE"  ]; then
    PID=$(cat $PIDFILE)
    if ps -p $PID > /dev/null; then
        echo "Job already running. Aborting."
        exit 1
    else
        echo "PID file existing, but Job is not running. Starting..."
    fi
fi

echo "Starting job..."
echo $BASHPID > /tmp/plexWatchJob.pid

while [ -f "$PIDFILE"  ]; do
    sleep $SLEEPTIME
    /opt/plexWatch/plexWatch.pl
done

echo "Job ended."
