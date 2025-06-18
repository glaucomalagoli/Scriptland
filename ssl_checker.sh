#!/bin/bash

#./ssl_checker.sh exemplo.com 443

DOMAIN="$1"
PORT="$2"

validate_input() {
    if [[ -z "$DOMAIN" || -z "$PORT" ]]; then
        printf "Usage: %s <domain> <port>\n" "$0" >&2
        return 1
    fi
    if ! [[ "$PORT" =~ ^[0-9]+$ && "$PORT" -ge 1 && "$PORT" -le 65535 ]]; then
        printf "Invalid port: %s. Must be a number between 1 and 65535\n" "$PORT" >&2
        return 1
    fi
}

get_cert_expiry_date() {
    local output; output=$(echo | openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:$PORT" 2>/dev/null)
    if [[ -z "$output" ]]; then
        printf "Failed to connect to %s:%s or retrieve certificate\n" "$DOMAIN" "$PORT" >&2
        return 1
    fi

    local expiry; expiry=$(printf "%s" "$output" | openssl x509 -noout -enddate 2>/dev/null)
    if [[ -z "$expiry" ]]; then
        printf "Unable to extract certificate expiry date from %s:%s\n" "$DOMAIN" "$PORT" >&2
        return 1
    fi

    local date_string; date_string=$(printf "%s" "$expiry" | cut -d= -f2)
    if [[ -z "$date_string" ]]; then
        printf "Invalid expiry date format for %s:%s\n" "$DOMAIN" "$PORT" >&2
        return 1
    fi

    CERT_EXPIRY_DATE="$date_string"
}

calculate_days_until_expiry() {
    local expiry_epoch; expiry_epoch=$(date -d "$CERT_EXPIRY_DATE" +%s 2>/dev/null)
    if [[ -z "$expiry_epoch" || "$expiry_epoch" -le 0 ]]; then
        printf "Failed to convert expiry date to epoch\n" >&2
        return 1
    fi

    local current_epoch; current_epoch=$(date +%s)
    local diff=$(( expiry_epoch - current_epoch ))

    if [[ "$diff" -lt 0 ]]; then
        DAYS_LEFT=0
    else
        DAYS_LEFT=$(( diff / 86400 ))
    fi
}

report_ssl_status() {
    if [[ "$DAYS_LEFT" -le 90 ]]; then
        printf "Critical: SSL certificate will expire in %d days\n" "$DAYS_LEFT"
    else
        printf "Certificate is valid. Expires in %d days\n" "$DAYS_LEFT"
    fi
}

main() {
    if ! validate_input; then return 1; fi
    if ! get_cert_expiry_date; then return 1; fi
    if ! calculate_days_until_expiry; then return 1; fi
    report_ssl_status
}

main
