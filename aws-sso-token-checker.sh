#!/bin/bash

# Locate the AWS SSO cache directory
SSO_CACHE_DIR="$HOME/.aws/sso/cache"

# Find the latest token file
TOKEN_FILE=$(ls -t "$SSO_CACHE_DIR"/*.json 2>/dev/null | head -n 1)

if [[ ! -f "$TOKEN_FILE" ]]; then
    echo "No AWS SSO token found. Run 'aws sso login --profile <PROFILE_NAME>' first."
    exit 1
fi

# Try to extract registrationExpiresAt first, then fall back to expiresAt
EXPIRATION=$(grep -o '"registrationExpiresAt": "[^"]*' "$TOKEN_FILE" | cut -d'"' -f4)

if [[ -z "$EXPIRATION" ]]; then
    EXPIRATION=$(grep -o '"expiresAt": "[^"]*' "$TOKEN_FILE" | cut -d'"' -f4)
fi

if [[ -z "$EXPIRATION" ]]; then
    echo "Could not determine token expiration. Check AWS SSO login."
    exit 1
fi

# Convert expiration time to Unix timestamp
EXPIRATION_TS=$(date -u -d "$EXPIRATION" +%s)
CURRENT_TS=$(date -u +%s)

# Calculate token age in hours
TOKEN_AGE_HOURS=$(( (CURRENT_TS - EXPIRATION_TS) / 3600 ))
TIME_REMAINING_HOURS=$(( (EXPIRATION_TS - CURRENT_TS) / 3600 ))

if [[ $CURRENT_TS -ge $EXPIRATION_TS ]]; then
    echo "⚠️ Your AWS SSO token has expired. Run 'aws sso login --profile <PROFILE_NAME>' to refresh."
else
    echo "✅ Your token is valid. It will expire in $TIME_REMAINING_HOURS hours."
fi
echo "AWS SSO Token Expiration Time: $EXPIRATION UTC"
echo "Token Age: $TOKEN_AGE_HOURS hours old"
