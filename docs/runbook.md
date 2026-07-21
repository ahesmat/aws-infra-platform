# Incident Runbook — aws-infra-platform

## Overview
This runbook covers common failure scenarios for the aws-infra-platform infrastructure.
Run `bash scripts/health-check.sh` first to identify which component is failing.

---

## Scenario 1: Site is Down (HTTP non-200)

### Symptoms
- `health-check.sh` reports site DOWN
- `https://devops.reachlyapp.com` returns error or times out

### Investigation Steps

**1. Check ALB target health:**
```bash
aws elbv2 describe-target-health \
  --target-group-arn $(aws elbv2 describe-target-groups \
    --names aws-infra-platform-dev-tg \
    --query 'TargetGroups[0].TargetGroupArn' --output text)
```

**2. Check EC2 instance state:**
```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=aws-infra-platform-dev-ec2" \
  --query 'Reservations[0].Instances[0].[State.Name,InstanceId]' \
  --output table
```

**3. Check nginx status via SSM:**
```bash
aws ssm send-command \
  --instance-ids INSTANCE_ID \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["systemctl status nginx"]' \
  --query 'Command.CommandId' --output text
```

### Resolution
- If EC2 is stopped: `aws ec2 start-instances --instance-ids INSTANCE_ID`
- If nginx is stopped: run SSM command `systemctl start nginx`
- If target is unhealthy: check security group rules allow ALB → EC2 on port 80

---

## Scenario 2: SSL Certificate Error

### Symptoms
- Browser shows certificate warning
- `curl -I https://devops.reachlyapp.com` returns SSL error

### Investigation Steps

**1. Check ACM certificate status:**
```bash
aws acm list-certificates \
  --query 'CertificateSummaryList[?DomainName==`devops.reachlyapp.com`].[DomainName,Status]' \
  --output table
```

**2. Check DNS delegation:**
```bash
dig devops.reachlyapp.com NS @1.1.1.1
```

### Resolution
- If certificate is PENDING_VALIDATION: NS records at Namecheap don't match Route 53 zone
- Update Namecheap NS records to match `terraform output route53_name_servers`
- Certificate auto-renews 60 days before expiry — no manual action needed

---

## Scenario 3: EC2 Not Reachable via SSM

### Symptoms
- `health-check.sh` reports EC2 SSM Offline
- Ansible playbook fails with TargetNotConnected

### Investigation Steps

**1. Check SSM agent status:**
```bash
aws ssm describe-instance-information \
  --query 'InstanceInformationList[*].[InstanceId,PingStatus]' \
  --output table
```

**2. Check IAM role attached to instance:**
```bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=aws-infra-platform-dev-ec2" \
  --query 'Reservations[0].Instances[0].IamInstanceProfile.Arn' \
  --output text
```

### Resolution
- If SSM agent is offline: reboot instance via EC2 console
- If IAM profile missing: verify `aws_iam_instance_profile.ec2` is attached in Terraform
- New instances need ~90 seconds after launch before SSM registers

---

## Scenario 4: Terraform Apply Fails in Pipeline

### Symptoms
- GitHub Actions CD pipeline fails at Terraform Apply step
- State lock error

### Investigation Steps

**1. Check for stale state lock:**
The pipeline uses S3 native locking. If a previous run was interrupted, force unlock:
```bash
terraform force-unlock LOCK_ID
```
Lock ID is shown in the error message.

**2. Check AWS credentials:**
- Verify `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` secrets in GitHub are current
- Sandbox credentials expire — update them at the start of each session

### Resolution
- Update GitHub secrets with fresh sandbox credentials
- Re-run the failed workflow via Actions → Re-run failed jobs

---

## Scenario 5: High CPU Alarm Triggered

### Symptoms
- Email alert received from SNS topic
- CloudWatch alarm `aws-infra-platform-dev-cpu-high` in ALARM state

### Investigation Steps

**1. Check current CPU:**
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=INSTANCE_ID \
  --start-time $(date -u -v-10M +%Y-%m-%dT%H:%M:%S 2>/dev/null || date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%S)Z \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 60 \
  --statistics Average \
  --output table
```

**2. Check nginx processes via SSM:**
```bash
aws ssm send-command \
  --instance-ids INSTANCE_ID \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=["top -bn1 | head -20"]' \
  --query 'Command.CommandId' --output text
```

### Resolution
- t3.micro has 2 vCPUs — sustained high CPU may indicate traffic spike or runaway process
- For a portfolio project: investigate and restart nginx if needed
- For production: implement Auto Scaling Group with scale-out policy

---

## Useful Commands

```bash
# Run health check
bash scripts/health-check.sh

# View recent logs
bash scripts/log-summary.sh

# Check running resources and costs
bash scripts/cost-estimate.sh

# SSH-free shell access to EC2
aws ssm start-session --target INSTANCE_ID

# View CloudWatch dashboard
# AWS Console → CloudWatch → Dashboards → aws-infra-platform-dev
```
