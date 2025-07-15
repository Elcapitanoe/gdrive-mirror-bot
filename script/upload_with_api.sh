#!/bin/bash
set -e

# Vars from secrets
CLIENT_ID="${GDRIVE_CLIENT_ID}"
CLIENT_SECRET="${GDRIVE_CLIENT_SECRET}"
REFRESH_TOKEN="${GDRIVE_REFRESH_TOKEN}"
FOLDER_ID="${GDRIVE_FOLDER_ID}"

FILE_PATH="$1"
FILE_NAME=$(basename "$FILE_PATH")
MIME_TYPE=$(file --mime-type -b "$FILE_PATH")

# Get access token
ACCESS_TOKEN=$(curl -s -X POST https://oauth2.googleapis.com/token \
  -d client_id="${CLIENT_ID}" \
  -d client_secret="${CLIENT_SECRET}" \
  -d refresh_token="${REFRESH_TOKEN}" \
  -d grant_type=refresh_token | jq -r .access_token)

# Upload file
UPLOAD_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -F "metadata={name: '$FILE_NAME', parents: ['${FOLDER_ID}']};type=application/json;charset=UTF-8" \
  -F "file=@${FILE_PATH};type=${MIME_TYPE}" \
  https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart)

# Get File ID
FILE_ID=$(echo "$UPLOAD_RESPONSE" | jq -r .id)

# Make file public
curl -s -X POST \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"role": "reader", "type": "anyone"}' \
  "https://www.googleapis.com/drive/v3/files/${FILE_ID}/permissions"

# Output sharable link
echo "https://drive.google.com/file/d/${FILE_ID}/view?usp=sharing"
