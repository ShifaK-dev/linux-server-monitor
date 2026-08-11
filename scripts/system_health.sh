#!/bin/bash

# ==========================================
# Linux Server Health Monitoring
# ==========================================

print_header() {
    echo "===================================="
    echo "       LINUX SERVER HEALTH"
    echo "===================================="
}

get_system_info() {
    echo "Hostname       : $(hostname)"
    echo "OS             : $(grep '^PRETTY_NAME=' /etc/os-release | cut -d'"' -f2)"
    echo "Kernel         : $(uname -r)"
    echo "Uptime         : $(uptime -p)"
}

check_cpu() {
    CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk -F',' '{print $4}' | awk '{print $1}' | tr -d '%')
    CPU_USAGE=$(awk "BEGIN {print 100 - $CPU_IDLE}")

    echo "CPU usage      : ${CPU_USAGE}%"
}

check_memory() {
    MEM_TOTAL=$(free | grep Mem | awk '{print $2}')
    MEM_USED=$(free | grep Mem | awk '{print $3}')
    MEM_USAGE=$(awk "BEGIN {printf \"%.1f\", ($MEM_USED / $MEM_TOTAL) * 100}")

    echo "Memory usage   : ${MEM_USAGE}%"
}

check_disk() {
    DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | tr -d '%')

    if [ "$DISK_USAGE" -ge 90 ]; then
        DISK_STATUS="CRITICAL"
    elif [ "$DISK_USAGE" -ge 70 ]; then
        DISK_STATUS="WARNING"
    else
        DISK_STATUS="HEALTHY"
    fi

    echo "Disk usage     : ${DISK_USAGE}%"
    echo "Disk status    : ${DISK_STATUS}"
}

check_network() {
    if ping -c 1 -W 1 8.8.8.8 > /dev/null; then
        NETWORK_STATUS="HEALTHY"
    else
        NETWORK_STATUS="DOWN"
    fi

    echo "Network status : ${NETWORK_STATUS}"
}

check_ssh() {
    if sudo ss -tuln | grep -q ':22 '; then
        SSH_STATUS="LISTENING"
    else
        SSH_STATUS="DOWN"
    fi

    echo "SSH port 22    : ${SSH_STATUS}"
}

check_apache() {
    if systemctl is-active --quiet apache2; then
        APACHE_STATUS="RUNNING"
    else
        APACHE_STATUS="DOWN"
    fi

    echo "Apache         : ${APACHE_STATUS}"
}

check_web() {
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)

    if [ "$HTTP_CODE" -eq 200 ]; then
        HTTP_STATUS="HEALTHY"
    else
        HTTP_STATUS="UNHEALTHY"
    fi

    echo "HTTP status    : ${HTTP_CODE}"
    echo "Web health     : ${HTTP_STATUS}"
}

# ==========================================
# Main Program
# ==========================================

print_header

get_system_info

echo

check_cpu
check_memory
check_disk

echo

check_network
check_ssh
check_apache
check_web

echo
echo "===================================="
