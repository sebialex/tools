#!/bin/sh
### BEGIN INIT INFO
# Provides:          lowMemAlert.sh
# Required-Start:    $local_fs $network $named $time $syslog
# Required-Stop:     $local_fs $network $named $time $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       Provides warning when system memory is too low, and will stop chromium if running
### END INIT INFO

# See http://refspecs.linuxbase.org/LSB_4.1.0/LSB-Core-generic/LSB-Core-generic/facilname.html for Required-Start/Stop options

name=lowMemAlert
dir_path=/usr/local/bin
path_to_start=$dir_path/${name}.sh
path_to_log=/var/log/${name}/log.txt

process_name="$name"

start_() {
   daemon --name=${name} --output=$path_to_log sh $path_to_start
}

stop_() {
   kill -9 $(ps aux | grep $process_name | grep -v grep | awk '{print $2}')
}

case "$1" in
  start)
    #daemon --name="lowMemAlert" --output=/var/log/low-mem-alert.txt sh /usr/local/bin/low-mem-alert
    start_
    ;;
  stop)    
    stop_
    ;;
  restart)
    stop_
    start_
    ;;
  status)
    if [ -e $path_to_log ]; then
        tail $path_to_log
    else 
        echo "Not running"
    fi
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status|uninstall}"
esac