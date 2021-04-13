#!/bin/bash

###############################################################################
#
# get_usage.sh: script to measure CPU and memory usage of avira ICAP daemon
#
# Copyright (c) 2021 Open Systems AG, Switzerland
# All Rights Reserved.
#
# This scripts monitor the daemon av-icapd and write the results to a file.
# $1 is the path of the file where the results are written to.
#
###############################################################################

FILE="$1"
[ $# -eq 0 ] && { echo "Usage: $0 file-name"; exit 1; }


if [ ! -f "$FILE" ]
then
	mkdir -p "$(dirname "$FILE")" && touch "$FILE"
	echo "TIME,CPU,MEM" > "$FILE";
fi

pid="$(pgrep av-icapd)"
if [ ! -z  $pid ]
then
	top -b -n 2 -d 0.2 -p $(pgrep av-icapd) | tail -1 | awk -v t="$(date -u +%s)" '{print t"," $9 "," $10}' >> "$FILE"
fi


