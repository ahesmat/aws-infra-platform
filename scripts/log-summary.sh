#!/bin/bash

echo "=== Nginx Log Summary (Last 30 minutes) ==="
echo ""

START_TIME=$(date -u -v-30M +%s000 2>/dev/null || date -u -d '30 minutes ago' +%s000)
END_TIME=$(date -u +%s000)

echo "--- Recent Access Log Entries ---"
aws logs filter-log-events \
  --log-group-name "/aws-infra-platform/dev/nginx/access" \
  --start-time "$START_TIME" \
  --end-time "$END_TIME" \
  --query 'events[-10:].message' \
  --output text 2>/dev/null | head -20 || echo "No access logs found"

echo ""
echo "--- Recent Error Log Entries ---"
aws logs filter-log-events \
  --log-group-name "/aws-infra-platform/dev/nginx/error" \
  --start-time "$START_TIME" \
  --end-time "$END_TIME" \
  --query 'events[-10:].message' \
  --output text 2>/dev/null | head -20 || echo "No error logs found"

echo ""
echo "=== Log Summary Complete ==="
