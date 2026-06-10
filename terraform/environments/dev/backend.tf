terraform {
  backend "s3" {
    bucket         = "tfstate-aws-infra-platform-065209282584"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
