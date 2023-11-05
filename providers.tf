terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIAQEJDXE6BK6S5KSNM"
  secret_key = "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"
}
