#!/bin/bash

# Interactive script to sign a new client certificate using nebula-cert

echo "Signing a new client certificate with nebula-cert"

# Check if ca.key exists
if [[ ! -f "ca.key" ]]; then
    echo "Error: ca.key file not found! Please ensure it exists before proceeding."
    exit 1
fi

CLIENT_NAME="client"
IP_ADDRESS=""

# Prompt for required IP address
read -p "Enter IP address (CIDR notation): " IP_ADDRESS

# Prompt for optional parameters
echo "Optional parameters: Press Enter to skip"
read -p "Enter groups (comma separated): " GROUPS
read -p "Enter duration (e.g., 24h, 30m): " DURATION
read -p "Enter subnets (comma separated, optional): " SUBNETS

# Set output file paths
OUT_CRT="${CLIENT_NAME}.crt"
OUT_KEY="${CLIENT_NAME}.key"

# Construct command
CMD="nebula-cert sign -name $CLIENT_NAME -ip $IP_ADDRESS -out-crt $OUT_CRT -out-key $OUT_KEY"

# Add optional parameters if provided
[[ -n "$GROUPS" ]] && CMD+=" -groups $GROUPS"
[[ -n "$DURATION" ]] && CMD+=" -duration $DURATION"
[[ -n "$SUBNETS" ]] && CMD+=" -subnets $SUBNETS"

# Execute command
echo "Executing: $CMD"
$CMD

# Check for success
if [[ $? -eq 0 ]]; then
    echo "Certificate successfully created: $OUT_CRT"
    
    # Check if client.yml and ca.crt exist before zipping
    if [[ ! -f "client.yml" ]]; then
        echo "Warning: client.yml not found! It will not be included in the zip."
    fi
    if [[ ! -f "ca.crt" ]]; then
        echo "Warning: ca.crt not found! It will not be included in the zip."
    fi

    # Create a zip archive
    ZIP_FILE="${CLIENT_NAME}.zip"
    zip -j $ZIP_FILE $OUT_CRT $OUT_KEY client.yml ca.crt 2>/dev/null
    echo "Created archive: $ZIP_FILE"
else
    echo "Error signing the certificate. Please check the parameters and try again."
fi
