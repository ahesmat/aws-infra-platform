#!/bin/bash
set -e

ROOT_DIR="$(pwd)"
ENV_FILE="$ROOT_DIR/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: .env file not found at $ENV_FILE"
  echo "Make sure you're in the repo root and .env exists."
  return 1 2>/dev/null || exit 1
fi

echo "Loading credentials from .env..."
export $(grep -v '^#' "$ENV_FILE" | xargs)

echo "Verifying AWS credentials..."
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "Connected — Account ID: $ACCOUNT_ID"

BUCKET_NAME="tfstate-aws-infra-platform-${ACCOUNT_ID}"
REGION="${AWS_DEFAULT_REGION:-us-east-1}"

echo "Creating Terraform state bucket: $BUCKET_NAME..."
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" 2>/dev/null || echo "Bucket already exists, skipping."

aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration \
    '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

echo "Creating DynamoDB lock table..."
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION" 2>/dev/null || echo "DynamoDB table already exists, skipping."

echo "Updating backend.tf with account ID $ACCOUNT_ID..."
sed -i '' "s/tfstate-aws-infra-platform-[A-Za-z0-9_]*/tfstate-aws-infra-platform-${ACCOUNT_ID}/" \
  "$ROOT_DIR/terraform/environments/dev/backend.tf"

echo "Reinitializing Terraform backend..."
cd "$ROOT_DIR/terraform/environments/dev"
terraform init -reconfigure

echo ""
echo "Session setup complete. You can now run:"
echo "  terraform plan"
