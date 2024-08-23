terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.64.0"
    }
  }
  backend "s3" {
    bucket = "state-remote-store"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }

    required_version = ">= 1.6.3"

}