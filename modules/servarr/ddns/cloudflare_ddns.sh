#!/usr/bin/env bash

# Requires ping, nc, curl, jq

# Exit immediately if a command exits with a non-zero status
set -e

# Configuration
# API_TOKEN="YOUR_API_TOKEN"
# ZONE_ID="YOUR_ZONE_ID"

# export DNS_RECORD_1="subdomain1.domain.com,RECORD_ID_1,true"
# export DNS_RECORD_2="subdomain2.domain.com,RECORD_ID_2,false"

# Constants
CLOUDFLARE_API_URL="https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records"
CLOUDFLARE_TRACE_URL="https://www.cloudflare.com/cdn-cgi/trace"

# Function to check internet connectivity
check_internet() {
    if ! ping -c 1 1.1.1.1 &> /dev/null; then
        echo "No internet connection. Exiting."
        exit 1
    fi
}

# Function to update DNS record
update_dns_record() {
    local record_id="$1"
    local subdomain="$2"
    local new_ip="$3"
    local proxied="$4"

    # Update DNS record using curl
    local response
    response=$(curl -s -X PUT "$CLOUDFLARE_API_URL/$record_id" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json" \
        --data '{
            "type": "A",
            "name": "'"$subdomain"'",
            "content": "'"$new_ip"'",
            "ttl": 1,
            "proxied": '"$proxied"'
        }')

    # Check if the update was successful using jq
    if echo "$response" | jq -e '.success' > /dev/null; then
        echo "DNS record for $subdomain updated successfully to $new_ip!"
    else
        local errors
        errors=$(echo "$response" | jq -r '.errors[] | .message')
        echo "Failed to update DNS record for $subdomain: $errors"
    fi
}

# Check for internet connectivity
check_internet

# Get the current public IP from Cloudflare
NEW_IP=$(curl -s "$CLOUDFLARE_TRACE_URL" | grep -oP 'ip=\K[^ ]+')

# Collect the records
mapfile -t DNS_RECORDS < <(printenv | grep '^DNS_RECORD_' | cut -d '=' -f 2)

# Print the array to verify
# echo "${DNS_RECORDS[@]}"

# Loop through the DNS_RECORDS array
for record in "${DNS_RECORDS[@]}"; do
    IFS=',' read -r subdomain record_id proxied <<< "$record"
    update_dns_record "$record_id" "$subdomain" "$NEW_IP" "$proxied"
done
