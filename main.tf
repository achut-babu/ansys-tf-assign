# Configure AWS Provider
provider "aws" {
  region = var.aws_region  
}

# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
    Environment = "production"
  }
}

