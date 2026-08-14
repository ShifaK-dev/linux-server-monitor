#!/bin/bash

# ==========================================
# Linux Server Health Monitoring
# ==========================================
OVERALL_STATUS="HEALTHY"
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
    CPU_USAGE=$(awk "BEGIN {printf \"%.1f\", 100 - $CPU_IDLE}")

    if awk "BEGIN {exit !($CPU_USAGE >= 85)}"; then
        CPU_STATUS="CRITICAL"
        OVERALL_STATUS="CRITICAL"
    elif awk "BEGIN {exit !($CPU_USAGE >= 70)}"; then
        CPU_STATUS="WARNING"
        [ "$OVERALL_STATUS" = "HEALTHY" ] && OVERALL_STATUS="WARNING"
    else
        CPU_STATUS="HEALTHY"
    fi

    echo "CPU usage      : ${CPU_USAGE}%"
    echo "CPU status     : ${CPU_STATUS}"
}
check_memory() {
    MEM_TOTAL=$(free | awk '/Mem:/ {print $2}')
    MEM_USED=$(free | awk '/Mem:/ {print $3}')
    MEM_USAGE=$(awk "BEGIN {printf \"%.1f\", ($MEM_USED / $MEM_TOTAL) * 100}")

    if awk "BEGIN {exit !($MEM_USAGE >= 85)}"; then
        MEM_STATUS="CRITICAL"
        OVERALL_STATUS="CRITICAL"
    elif awk "BEGIN {exit !($MEM_USAGE >= 70)}"; then
        MEM_STATUS="WARNING"
        [ "$OVERALL_STATUS" = "HEALTHY" ] && OVERALL_STATUS="WARNING"
    else
        MEM_STATUS="HEALTHY"
    fi

    echo "Memory usage   : ${MEM_USAGE}%"
    echo "Memory status  : ${MEM_STATUS}"
}

check_disk() {
    DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | tr -d '%')

    if [ "$DISK_USAGE" -ge 90 ]; then
        DISK_STATUS="CRITICAL"
        OVERALL_STATUS="CRITICAL"
    elif [ "$DISK_USAGE" -ge 70 ]; then
        DISK_STATUS="WARNING"
        [ "$OVERALL_STATUS" = "HEALTHY" ] && OVERALL_STATUS="WARNING"
    else
        DISK_STATUS="HEALTHY"
    fi

    echo "Disk usage     : ${DISK_USAGE}%"
    echo "Disk status    : ${DISK_STATUS}"
}

check_network() {
    if ping -c 1 -W 1 8.8.8.8 > /dev/null 2>&1; then
        NETWORK_STATUS="HEALTHY"
    else
        NETWORK_STATUS="DOWN"
        OVERALL_STATUS="CRITICAL"
    fi

    echo "Network status : ${NETWORK_STATUS}"
}

check_ssh() {
    if ss -tuln | grep -q ':22 '; then
        SSH_STATUS="LISTENING"
    else
        SSH_STATUS="DOWN"
        OVERALL_STATUS="CRITICAL"
    fi

    echo "SSH port 22    : ${SSH_STATUS}"
}

check_apache() {
    if ! command -v apache2 > /dev/null 2>&1; then
        APACHE_STATUS="NOT CONFIGURED"
    elif systemctl is-active --quiet apache2; then
        APACHE_STATUS="RUNNING"
    else
        APACHE_STATUS="DOWN"
        OVERALL_STATUS="CRITICAL"
    fi

    echo "Apache         : ${APACHE_STATUS}"
}

check_web() {
    if ! command -v curl > /dev/null 2>&1; then
        HTTP_STATUS="NOT CONFIGURED"
        HTTP_CODE="N/A"
    else
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 http://localhost)

        if [ "$HTTP_CODE" = "200" ]; then
            HTTP_STATUS="HEALTHY"
        elif [ "$HTTP_CODE" = "000" ]; then
            HTTP_STATUS="NOT CONFIGURED"
        else
            HTTP_STATUS="UNHEALTHY"
            [ "$OVERALL_STATUS" = "HEALTHY" ] && OVERALL_STATUS="WARNING"
        fi
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
echo "Overall status : ${OVERALL_STATUS}"
echo "===================================="
