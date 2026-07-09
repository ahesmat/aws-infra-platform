terraform {
  backend "s3" {
    bucket       = "tfstate-aws-infra-platform-174990409836"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
