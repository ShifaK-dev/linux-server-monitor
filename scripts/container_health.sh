#!/bin/bash

echo "===================================="
echo "       DOCKER CONTAINER HEALTH"
echo "===================================="

echo "Hostname       : $(hostname)"
echo "OS             : $(grep '^PRETTY_NAME=' /etc/os-release | cut -d'"' -f2)"
echo "Kernel         : $(uname -r)"

CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk -F',' '{print $4}' | awk '{print $1}' | tr -d '%')
CPU_USAGE=$(awk "BEGIN {printf \"%.1f\", 100 - $CPU_IDLE}")
echo "CPU usage      : ${CPU_USAGE}%"

MEM_TOTAL=$(free | awk '/Mem:/ {print $2}')
MEM_USED=$(free | awk '/Mem:/ {print $3}')
MEM_USAGE=$(awk "BEGIN {printf \"%.1f\", ($MEM_USED / $MEM_TOTAL) * 100}")
echo "Memory usage   : ${MEM_USAGE}%"

DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}')
echo "Disk usage     : ${DISK_USAGE}"

if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
    NETWORK_STATUS="HEALTHY"
else
    NETWORK_STATUS="DOWN"
fi

echo "Network status : ${NETWORK_STATUS}"

echo "===================================="
