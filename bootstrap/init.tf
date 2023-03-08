terraform {
  backend "s3" {
    bucket         = "cocopaps-terraform-states"
    key            = "infra/bootstrap.tf"
    region         = "eu-west-3"
    dynamodb_table = "cocopaps-terraform-locks"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}
