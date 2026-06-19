terraform {
  backend "s3" {
    bucket = var.backend.bucket
    key    = var.backend.key
    region = var.backend.region
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }
}

provider "aws" {
  region = var.project.region
  default_tags {
    tags = {
      Name = var.project.name
    }
  }
}
