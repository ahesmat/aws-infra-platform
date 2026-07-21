#!/bin/bash
set -e

echo "=== AWS Infrastructure Health Check ==="
echo ""

# Check site HTTP response
echo "Checking site availability..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://devops.reachlyapp.com --max-time 10 || echo "000")

if [ "$HTTP_STATUS" = "200" ]; then
  echo "✅ Site is UP — https://devops.reachlyapp.com (HTTP $HTTP_STATUS)"
else
  echo "❌ Site is DOWN or unreachable (HTTP $HTTP_STATUS)"
fi

echo ""

# Check EC2 SSM registration
echo "Checking EC2 SSM connectivity..."
INSTANCE_ID=$(aws ssm get-parameter \
  --name "/app/aws-infra-platform/dev/instance-id" \
  --query 'Parameter.Value' \
  --output text 2>/dev/null || echo "")

if [ -z "$INSTANCE_ID" ]; then
  echo "❌ Could not retrieve instance ID from SSM Parameter Store"
else
  SSM_STATUS=$(aws ssm describe-instance-information \
    --filters "Key=InstanceIds,Values=$INSTANCE_ID" \
    --query 'InstanceInformationList[0].PingStatus' \
    --output text 2>/dev/null || echo "Unknown")

  if [ "$SSM_STATUS" = "Online" ]; then
    echo "✅ EC2 instance $INSTANCE_ID is SSM Online"
  else
    echo "❌ EC2 instance $INSTANCE_ID SSM status: $SSM_STATUS"
  fi
fi

echo ""

# Check ALB target health
echo "Checking ALB target group health..."
TG_ARN=$(aws elbv2 describe-target-groups \
  --names "aws-infra-platform-dev-tg" \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text 2>/dev/null || echo "")

if [ -n "$TG_ARN" ]; then
  HEALTH=$(aws elbv2 describe-target-health \
    --target-group-arn "$TG_ARN" \
    --query 'TargetHealthDescriptions[0].TargetHealth.State' \
    --output text 2>/dev/null || echo "unknown")

  if [ "$HEALTH" = "healthy" ]; then
    echo "✅ ALB target is healthy"
  else
    echo "❌ ALB target health: $HEALTH"
  fi
else
  echo "❌ Could not find target group"
fi

echo ""
echo "=== Health Check Complete ==="
