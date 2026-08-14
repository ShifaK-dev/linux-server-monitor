#!/bin/bash

# ==========================================
# Linux Server Log Monitoring
# ==========================================

AUTH_LOG="/var/log/auth.log"
SYSLOG="/var/log/syslog"

OVERALL_STATUS="HEALTHY"

print_header() {
    echo "===================================="
    echo "         LOG MONITORING"
    echo "===================================="
}

check_auth_log() {
    CUTOFF=$(date -d '15 minutes ago' '+%Y-%m-%dT%H:%M:%S')

    AUTH_FAILURES=$(sudo awk -v cutoff="$CUTOFF" \
        '$0 >= cutoff && /sshd\[[0-9]+\]:.*Failed password|sshd\[[0-9]+\]:.*authentication failure/' \
        "$AUTH_LOG" | wc -l)

    if [ "$AUTH_FAILURES" -ge 5 ]; then
        AUTH_STATUS="CRITICAL"
        OVERALL_STATUS="CRITICAL"
    elif [ "$AUTH_FAILURES" -ge 1 ]; then
        AUTH_STATUS="WARNING"
        [ "$OVERALL_STATUS" = "HEALTHY" ] && OVERALL_STATUS="WARNING"
    else
        AUTH_STATUS="HEALTHY"
    fi

    echo "Auth failures  : ${AUTH_FAILURES}"
    echo "Auth status    : ${AUTH_STATUS}"
}

check_system_log() {
    CUTOFF=$(date -d '15 minutes ago' '+%Y-%m-%dT%H:%M:%S')

    OOM_EVENTS=$(sudo awk -v cutoff="$CUTOFF" \
        '$0 >= cutoff && /oom-kill|out of memory|Out of memory/' \
        "$SYSLOG" | wc -l)

    KERNEL_ERRORS=$(sudo awk -v cutoff="$CUTOFF" \
        '$0 >= cutoff && /kernel.*error|kernel.*BUG|kernel.*Oops/' \
        "$SYSLOG" | wc -l)

    SERVICE_FAILURES=$(sudo awk -v cutoff="$CUTOFF" \
        '$0 >= cutoff && /systemd.*: .*failed|systemd.*: .*Failed/' \
        "$SYSLOG" | wc -l)

    SYSTEM_ERRORS=$((OOM_EVENTS + KERNEL_ERRORS + SERVICE_FAILURES))

    if [ "$OOM_EVENTS" -ge 1 ]; then
        SYSTEM_STATUS="CRITICAL"
        OVERALL_STATUS="CRITICAL"
    elif [ "$KERNEL_ERRORS" -ge 1 ] || [ "$SERVICE_FAILURES" -ge 1 ]; then
        SYSTEM_STATUS="WARNING"
        [ "$OVERALL_STATUS" = "HEALTHY" ] && OVERALL_STATUS="WARNING"
    else
        SYSTEM_STATUS="HEALTHY"
    fi

    echo "System errors  : ${SYSTEM_ERRORS}"
    echo "System status  : ${SYSTEM_STATUS}"
}

print_header

check_auth_log
check_system_log

echo
echo "Overall status : ${OVERALL_STATUS}"
echo "===================================="
