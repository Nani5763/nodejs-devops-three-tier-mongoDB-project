terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.64.0"
    }
  }
  backend "s3" {
    bucket = "eks-buckets"
    key    = "eks/terraform.tfstate"
    region = "ap-south-1"
  }

    required_version = ">= 1.6.3"

}