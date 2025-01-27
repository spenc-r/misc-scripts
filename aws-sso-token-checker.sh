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

TIME_REMAINING_HOURS=$(( (EXPIRATION_TS - CURRENT_TS) / 3600 ))

if [[ $CURRENT_TS -ge $EXPIRATION_TS ]]; then
    echo "⚠️ Your AWS SSO token has expired. Run 'aws sso login --profile <PROFILE_NAME>' to refresh."
fi

# if token age is less than 1 week, print warning
if [[ $TIME_REMAINING_HOURS -lt 168 ]]; then
    echo "⚠️ Your AWS SSO token is valid for $TIME_REMAINING_HOURS more hours. Consider refreshing with 'aws sso login --profile <PROFILE_NAME>.'"
fi