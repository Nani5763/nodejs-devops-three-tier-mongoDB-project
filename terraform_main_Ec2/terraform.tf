terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.64.0"
    }
  }


  backend "s3" {
    bucket = "finalproject57"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }

    required_version = ">= 1.6.3"
}
provider "aws" {
  region = "us-east-1"
}

