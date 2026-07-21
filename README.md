# AWS Infrastructure Platform

Production-grade cloud infrastructure built with Terraform, deployed via GitHub Actions CI/CD, with full observability and security hardening.

Hosts a live resume page for **Ahmed Esmat — Cloud & DevOps Engineer**, deployed via Ansible + Jinja2 over AWS SSM with no SSH access.

**Live site:** [https://devops.reachlyapp.com](https://devops.reachlyapp.com)

---

## Architecture

Internet → Route 53 → ALB (HTTPS/443) → EC2 nginx (private subnet)
↓
CloudWatch Logs + Metrics + Alarms → SNS → Email


- **VPC:** Public and private subnets across 2 AZs, NAT gateway for outbound traffic
- **EC2:** t3.micro in private subnet, no SSH — SSM Session Manager only, IMDSv2 enforced
- **ALB:** HTTPS with ACM certificate, HTTP→HTTPS redirect, TLS 1.3
- **DNS:** Route 53 hosted zone for `devops.reachlyapp.com`, subdomain delegated from Namecheap

---

## Stack

| Layer | Technology |
|---|---|
| Infrastructure | Terraform |
| Configuration Management | Ansible + Jinja2 |
| CI/CD | GitHub Actions |
| Cloud | AWS (VPC, EC2, ALB, ACM, Route 53, CloudWatch, SNS, SSM) |
| Security | OIDC keyless auth, IMDSv2, encrypted volumes, VPC flow logs |
| Observability | CloudWatch agent, log groups, dashboard, SNS alarms, Insights queries |

---

## CI/CD Pipeline

Push to feature/* → PR to develop → Terraform CI (fmt, validate, tfsec)
↓
PR to main → Terraform Plan posted as PR comment
↓
Merge to main → Bootstrap (OIDC + Route53) → [approval gate] → Full Apply + Ansible Deploy


### Workflows
- **`terraform-ci.yml`** — lint, validate, tfsec security scan on every PR
- **`terraform-cd.yml`** — plan on PR to main, bootstrap + apply on merge with environment gate
- **`aws-auth-test.yml`** — manual OIDC authentication test

### Session Bootstrap (workflow_dispatch)
Each sandbox session runs the full pipeline automatically:
1. Creates S3 state bucket + DynamoDB lock table
2. Provisions OIDC resources and rotates `AWS_ROLE_ARN` secret
3. Creates Route 53 zone and posts NS records for DNS update
4. Pauses for manual Namecheap NS update → approval gate
5. Full `terraform apply` — 45 resources
6. Ansible deploys resume page and CloudWatch agent via SSM
7. Rotates `AWS_ROLE_ARN` secret with final session value

---

## Security Highlights

- **No SSH access** — EC2 accessible only via AWS SSM Session Manager
- **No stored AWS keys in CI** — GitHub Actions authenticates via OIDC federation
- **IMDSv2 enforced** — prevents SSRF-based credential theft
- **Encrypted at rest** — EC2 root volume, S3 state bucket, SNS topic
- **Least privilege IAM** — separate roles for EC2 (SSM + CloudWatch) and GitHub Actions
- **VPC flow logs** — all network traffic logged to CloudWatch
- **tfsec** — security scanning on every PR

---

## Observability

- **CloudWatch agent** — ships nginx access and error logs from EC2
- **Log groups** — `/aws-infra-platform/dev/nginx/access` and `/error` with 7-day retention
- **Dashboard** — EC2 CPU, ALB request count, ALB response time
- **Alarms** — CPU > 80% triggers SNS → email alert
- **Insights queries** — top requestors, error rates, request volume by time

---

## Repository Structure

- `.github/workflows/` — CI/CD workflow definitions
- `ansible/` — Ansible playbooks and Jinja2 templates for EC2 configuration
- `docs/runbook.md` — Incident response runbook
- `scripts/` — Operational scripts (health check, log summary, cost estimate, session bootstrap)
- `terraform/environments/dev/` — All Terraform resources (VPC, EC2, ALB, ACM, Route 53, CloudWatch, OIDC, SSM, S3)

---

## Runbook

See [docs/runbook.md](./docs/runbook.md) for incident response procedures covering:
- Site down / ALB unhealthy
- SSL certificate errors
- EC2 SSM connectivity issues
- Terraform pipeline failures
- High CPU alarm response

---

## Phases Completed

- [x] Phase 0 — Repo setup, branch strategy, branch protection
- [x] Phase 1 — AWS infrastructure (VPC, EC2, ALB, ACM, Route 53, IAM)
- [x] Phase 2 — GitHub Actions CI/CD (OIDC, lint, validate, tfsec, plan, apply, environment gates)
- [x] Phase 3 — Observability (CloudWatch agent, log groups, dashboard, SNS alarms, Insights)
- [x] Phase 4 — Security hardening (IMDSv2, encrypted volumes, VPC flow logs, tfsec remediation)
- [x] Phase 5 — Operational readiness (bash scripts, runbook, architecture diagram, README)
