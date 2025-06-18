#!/bin/bash

#chmod +x ssl_checker.sh
#./ssl_checker.sh www.ampm.com.br 443

DOMAIN="$1"
PORT="$2"

validate_input() {
    if [[ -z "$DOMAIN" || -z "$PORT" ]]; then
        echo "Usage: $0 <domain> <port>" >&2
        return 1
    fi
    if ! [[ "$PORT" =~ ^[0-9]+$ && "$PORT" -ge 1 && "$PORT" -le 65535 ]]; then
        echo "Invalid port: $PORT. Must be between 1 and 65535." >&2
        return 1
    fi
}

get_cert_expiry_date() {
    local cert_output
    cert_output=$(timeout 10 openssl s_client -servername "$DOMAIN" -connect "$DOMAIN:$PORT" < /dev/null 2>/dev/null)

    if [[ -z "$cert_output" ]]; then
        echo "Failed to retrieve certificate from $DOMAIN:$PORT" >&2
        return 1
    fi

    local expiry_line
    expiry_line=$(echo "$cert_output" | openssl x509 -noout -enddate 2>/dev/null)

    if [[ -z "$expiry_line" || ! "$expiry_line" =~ notAfter= ]]; then
        echo "Could not extract expiry date from certificate" >&2
        return 1
    fi

    # Ex: "Oct 25 23:59:59 2025 GMT" → "2025-10-25 23:59:59"
    raw_date="${expiry_line#notAfter=}"
    CERT_EXPIRY_DATE=$(date -jf "%b %d %T %Y %Z" "$raw_date" +"%Y-%m-%d %H:%M:%S" 2>/dev/null)

    if [[ -z "$CERT_EXPIRY_DATE" ]]; then
        echo "Failed to normalize expiry date: [$raw_date]" >&2
        return 1
    fi
}

calculate_days_until_expiry() {
    expiry_epoch=$(date -j -f "%Y-%m-%d %H:%M:%S" "$CERT_EXPIRY_DATE" +%s 2>/dev/null)
    if [[ $? -ne 0 || -z "$expiry_epoch" || "$expiry_epoch" -le 0 ]]; then
        echo "Failed to convert expiry date to epoch: [$CERT_EXPIRY_DATE]" >&2
        return 1
    fi

    current_epoch=$(date +%s)
    time_diff=$((expiry_epoch - current_epoch))

    if [[ "$time_diff" -lt 0 ]]; then
        DAYS_LEFT=0
    else
        DAYS_LEFT=$((time_diff / 86400))
    fi
}

report_ssl_status() {
    if [[ "$DAYS_LEFT" -le 90 ]]; then
        echo "⚠Critical: SSL certificate for $DOMAIN will expire in $DAYS_LEFT days"
    else
        echo "Certificate is valid. Expires in $DAYS_LEFT days"
    fi
}

main() {
    validate_input || exit 1
    get_cert_expiry_date || exit 1
    calculate_days_until_expiry || exit 1
    report_ssl_status
}

main
