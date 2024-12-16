#!/usr/bin/env bash

# Replace these variables with your own values
API_TOKEN="YOUR_CLOUDFLARE_API_TOKEN"
ZONE_ID="YOUR_ZONE_ID"  # Replace with your actual Zone ID

# Cloudflare API endpoint for listing DNS records
API_URL="https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records"

# Function to list DNS records
list_dns_records() {
    response=$(curl -s -X GET "$API_URL" \
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json")

    echo "$response" | jq -r '.result[] | "Record ID: \(.id), Name: \(.name), Type: \(.type)"'
}

# Main script execution
echo "Listing DNS records for Zone ID: $ZONE_ID"
list_dns_records
