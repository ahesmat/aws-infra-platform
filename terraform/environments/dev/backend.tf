terraform {
  backend "s3" {
    bucket       = "tfstate-aws-infra-platform-767398067547"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
