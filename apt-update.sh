#!/bin/bash

sudo pwd > /dev/null

# number of seconds needed without an update to trigger one 
THRESHOLD=60

# Seconds since last update
last=`stat -c %Y /var/cache/apt/`
# Seconds since epoch
current=`date +%s`
# The difference
diff=$((current - last))

echo "apt update was called $diff secongs ago"

if [ "$diff" -ge "$THRESHOLD"  ]; then
   sudo apt update
else
   echo "too recent, will not apt update"
fi
