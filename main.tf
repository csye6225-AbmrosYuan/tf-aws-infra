terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = var.profile
}

provider "aws" {
  alias  = "acm"
  region = "us-east-1"  
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "profile" {
  description = "AWS CLI profile to use."
  type        = string
  # default     = "terraform"
  default     = ""
}

variable "aws_region" {
  description = "AWS Region to deploy resources."
  type        = string
  default     = "us-east-1"
}
