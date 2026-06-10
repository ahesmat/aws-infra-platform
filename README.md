# AWS Infrastructure Platform

Production-grade cloud infrastructure built with Terraform, deployed via GitHub Actions CI/CD.

## Architecture
_diagram coming_

## Stack
- **Infrastructure:** Terraform, AWS (VPC, EC2, ALB, ACM, IAM, S3)
- **CI/CD:** GitHub Actions (OIDC, environment gates)
- **Observability:** CloudWatch, SNS alerting
- **Security:** SSM Session Manager, IMDSv2, encrypted state

## Phases
- [x] Phase 0: Repo setup & branching strategy
- [ ] Phase 1: AWS infrastructure (Terraform)
- [ ] Phase 2: CI/CD pipeline (GitHub Actions)
- [ ] Phase 3: Observability stack
- [ ] Phase 4: Security hardening
- [ ] Phase 5: Operational readiness

## Runbook
See [runbook.md](./docs/runbook.md)
