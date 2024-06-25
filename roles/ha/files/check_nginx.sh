#!/bin/bash
count=$(ps -ef |grep nginx |egrep -cv "grep|$$")

if [ "$count" -eq 0 ];then
#    systemctl restart nginx
#    sleep 3
#    if [ `ps -C nginx --no-header |wc -l` -eq 0 ] ; then
#        systemctl stop keepalived
#    fi
    exit 1
else
    exit 0
fi
