#!/bin/sh

THRESHOLD_PERC=80
THRESHOLD_KILL_PERC=95
SLEEP_INTERVAL=30

while :
do

    mem_used=$(free -m | awk '/^Mem/{print $3}')
    mem_total=$(free -m | awk '/^Mem/{print $2}')
    swap_used=$(free -m | awk '/^Swap/{print $3}')
    swap_total=$(free -m | awk '/^Swap/{print $2}')

    mem_total_used=$(expr $mem_used + $swap_used)
    mem_total=$(expr $mem_total + $swap_total)

    mem_total_used_100=$(expr $mem_total_used \* 100)
    mem_usage_perc=$(expr $mem_total_used_100 / $mem_total)

    message="$mem_total_used MB / $mem_total MB [${mem_usage_perc}%]"

    if [ "$mem_usage_perc" -gt "$THRESHOLD_PERC" ]; then
        /usr/bin/notify-send "Memory is running out!" "$message"
    fi

    if [ "$mem_usage_perc" -gt "$THRESHOLD_KILL_PERC" ]; then
        pkill chromium
    fi

    echo "$message"

    sleep $SLEEP_INTERVAL

done