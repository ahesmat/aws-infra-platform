terraform {
  backend "s3" {
    bucket       = "tfstate-aws-infra-platform-058264166251"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
