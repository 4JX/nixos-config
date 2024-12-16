#!/usr/bin/env bash

set -e  # Exit immediately if a command exits with a non-zero status

# Function to display usage
usage() {
    echo "Usage: $0 <server_interface> <server_endpoint> <user_ip>"
    exit 1
}

# Function to validate IP address format
validate_ip() {
    local ip="$1"
    if ! [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Error: Invalid IP address format: $ip"
        exit 1
    fi
}

# Function to check if a command exists
check_command() {
    command -v "$1" >/dev/null 2>&1 || { echo "Error: $1 is not installed." >&2; exit 1; }
}

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Check for required commands
check_command wg

# Check for required arguments
if [ "$#" -ne 3 ]; then
    usage
fi

SERVER_INTERFACE=$1
SERVER_ENDPOINT=$2
USER_IP=$3

# Validate user IP address
validate_ip "$USER_IP"

# Check if SERVER_ENDPOINT is an IP address or a domain name
if [[ "$SERVER_ENDPOINT" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # If it's an IP address, validate it
    validate_ip "$SERVER_ENDPOINT"
else
    # If it's a domain name, you can add additional validation if needed
    echo "Using domain name as server endpoint: $SERVER_ENDPOINT"
fi

# Extract the server's public key and listening port using the wg command
SERVER_PUBLIC_KEY=$(wg show "$SERVER_INTERFACE" public-key) || handle_error "Unable to retrieve the server public key. Please check the interface name."
SERVER_PORT=$(wg show "$SERVER_INTERFACE" listen-port) || handle_error "Unable to retrieve the server port. Please check the interface name."

# Generate user key pair
USER_PRIVATE_KEY=$(wg genkey)
USER_PUBLIC_KEY=$(echo "$USER_PRIVATE_KEY" | wg pubkey)

# Generate preshared key
PRESHARED_KEY=$(wg genpsk)

# Print user configuration file
cat <<EOF
[Interface]
# PublicKey = $USER_PUBLIC_KEY
PrivateKey = $USER_PRIVATE_KEY
Address = $USER_IP/24
# DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_ENDPOINT:$SERVER_PORT
AllowedIPs = 10.100.0.0/24
PresharedKey = $PRESHARED_KEY
PersistKeepAlive = 25
EOF

echo -e "\nServer config:"

# Fill out the peers template
cat <<EOF
peers = [
  {
    name = "user";
    publicKey = "$USER_PUBLIC_KEY";
    # presharedKey = "$PRESHARED_KEY";
    presharedKeyFile = "/use/me/for/your/preshared/key";
    allowedIPs = [ "$USER_IP/32" ];
  }
];
EOF

echo -e "\nClient config:"

# Add client configuration block
cat <<EOF
peers = [
  {
    publicKey = "$SERVER_PUBLIC_KEY";
    allowedIPs = [ "10.100.0.0/24" ];
    endpoint = "$SERVER_ENDPOINT:$SERVER_PORT";
    persistentKeepalive = 25;
  }
];
EOF