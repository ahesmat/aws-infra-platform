terraform {
  backend "s3" {
    bucket       = "tfstate-aws-infra-platform-370445361629"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
