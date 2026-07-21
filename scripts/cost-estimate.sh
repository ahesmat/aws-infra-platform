#!/bin/bash

echo "=== Running AWS Resources (Cost Estimate) ==="
echo ""

echo "--- EC2 Instances ---"
aws ec2 describe-instances \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,Tags[?Key==`Name`].Value|[0]]' \
  --output table 2>/dev/null

echo ""
echo "--- NAT Gateways ---"
aws ec2 describe-nat-gateways \
  --filter "Name=state,Values=available" \
  --query 'NatGateways[*].[NatGatewayId,State]' \
  --output table 2>/dev/null

echo ""
echo "--- Load Balancers ---"
aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[*].[LoadBalancerName,State.Code]' \
  --output table 2>/dev/null

echo ""
echo "--- Approximate Hourly Cost ---"
echo "EC2 t3.micro:     ~\$0.0104/hr"
echo "NAT Gateway:      ~\$0.045/hr + data"
echo "ALB:              ~\$0.008/hr + LCU"
echo "CloudWatch Logs:  ~\$0.50/GB ingested"
echo ""
echo "Estimated total:  ~\$0.065/hr (~\$1.56/day)"
echo ""
echo "=== Cost Estimate Complete ==="
