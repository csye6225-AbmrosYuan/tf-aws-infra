variable "aws_region" {
  description = "AWS Region to deploy resources."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "192.168.0.0/16"
}

variable "vpc_name" {
  description = "Name to assign to the VPC and its related resources."
  type        = string
  default     = "vpc"
}

# variable "availability_zones" {
#   description = "Optional: List of availability zones to use. If empty, available zones will be discovered."
#   type        = list(string)
#   default     = []
# }

# Number of bits to use for each subnet’s CIDR. For example, if your VPC CIDR is /16 and you want /20 subnets, set this to 4.
variable "subnet_bits" {
  description = "Number of additional bits for subnetting from the VPC CIDR."
  type        = number
  default     = 8
}



# number of public subnet(s)
variable "public_subnets_number" {
  description = "number of public subnet(s)"
  type        = number
  default     = 3
}

# number of private subnet(s)
variable "private_subnets_number" {
  description = "number of private subnet(s)"
  type        = number
  default     = 3
}


# An offset value for private subnets to avoid overlapping with public subnet CIDRs.
variable "private_subnet_offset" {
  description = "Offset for calculating CIDR blocks of private subnets relative to public subnets."
  type        = number
  default     = 32
}

variable "destination_cidr" {
  default = "0.0.0.0/0"
}


variable "profile" {
  description = "AWS CLI profile to use."
  type        = string
  # default     = "dev-user1-PowerUserAccess"
  default     = "dev"
}

variable "private_rt_name" {
  type    = string
  default = "vpc-private-rt"
}

variable "public_rt_name" {
  type    = string
  default = "vpc-public-rt"
}