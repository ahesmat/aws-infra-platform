#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: source scripts/new-session.sh ACCESS_KEY_ID,SECRET_ACCESS_KEY"
  return 1 2>/dev/null || exit 1
fi

ROOT_DIR="$(pwd)"

AWS_ACCESS_KEY_ID=$(echo "$1" | cut -d',' -f1)
AWS_SECRET_ACCESS_KEY=$(echo "$1" | cut -d',' -f2)

cat > "$ROOT_DIR/.env" << ENVEOF
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION=us-east-1
ENVEOF

echo ".env updated."
source "$ROOT_DIR/scripts/setup-session.sh"
