#!/usr/bin/env bash
set -euo pipefail

: "${GDRIVE_CLIENT_ID:?GDRIVE_CLIENT_ID is required}"
: "${GDRIVE_CLIENT_SECRET:?GDRIVE_CLIENT_SECRET is required}"
: "${GDRIVE_REFRESH_TOKEN:?GDRIVE_REFRESH_TOKEN is required}"
: "${GDRIVE_FOLDER_ID:=}"  

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <file_path> [FOLDER_ID_override]" >&2
  exit 1
fi

INPUT_PATH="$1"
OVERRIDE_FOLDER_ID="${2:-}"

if [[ ! -f "$INPUT_PATH" ]]; then
  echo "File tidak ditemukan: $INPUT_PATH" >&2
  exit 1
fi

FOLDER_ID="${OVERRIDE_FOLDER_ID:-${GDRIVE_FOLDER_ID}}"
if [[ -z "$FOLDER_ID" ]]; then
  echo "FOLDER_ID belum ditentukan. Set argumen ke-2 atau ENV GDRIVE_FOLDER_ID." >&2
  exit 1
fi

FILENAME="$(basename "$INPUT_PATH")"
MIME_TYPE="$(file --mime-type -b "$INPUT_PATH" || echo application/octet-stream)"

ACCESS_TOKEN="$(
  curl -sS -X POST https://oauth2.googleapis.com/token \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -d "client_id=${GDRIVE_CLIENT_ID}" \
    -d "client_secret=${GDRIVE_CLIENT_SECRET}" \
    -d "refresh_token=${GDRIVE_REFRESH_TOKEN}" \
    -d "grant_type=refresh_token" \
  | { jq -r '.access_token' 2>/dev/null || sed -n 's/.*"access_token"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'; }
)"

if [[ -z "$ACCESS_TOKEN" || "$ACCESS_TOKEN" == "null" ]]; then
  echo "Gagal mendapatkan access_token." >&2
  exit 1
fi

UPLOAD_RESP="$(
  curl -sS -X POST \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -F "metadata={\"name\":\"${FILENAME}\",\"parents\":[\"${FOLDER_ID}\"]};type=application/json; charset=UTF-8" \
    -F "file=@${INPUT_PATH};type=${MIME_TYPE}" \
    "https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart"
)"

FILE_ID="$(echo "$UPLOAD_RESP" | { jq -r '.id' 2>/dev/null || sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'; })"

if [[ -z "$FILE_ID" || "$FILE_ID" == "null" ]]; then
  echo "Gagal upload. Respon: $UPLOAD_RESP" >&2
  exit 1
fi

PERM_RESP="$(
  curl -sS -X POST \
    -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Content-Type: application/json" \
    -d '{"role":"reader","type":"anyone"}' \
    "https://www.googleapis.com/drive/v3/files/${FILE_ID}/permissions"
)" || true

echo "https://drive.google.com/file/d/${FILE_ID}/view?usp=sharing"
