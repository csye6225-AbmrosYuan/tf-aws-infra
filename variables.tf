variable "aws_region" {
  description = "AWS Region to deploy resources."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
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
  default     = "dev-user1-PowerUserAccess"
}


# variable "region_number" {
#   # Arbitrary mapping of region name to number to use in
#   # a VPC's CIDR prefix.
#   default = {
#     us-east-1      = 1
#     us-west-1      = 2
#     us-west-2      = 3
#     eu-central-1   = 4
#     ap-northeast-1 = 5
#   }
# }

# variable "az_number" {
#   # Assign a number to each AZ letter used in our configuration
#   default = {
#     a = 1
#     b = 2
#     c = 3
#     d = 4
#     e = 5
#     f = 6
#   }
# }

# # Retrieve the AZ where we want to create network resources
# # This must be in the region selected on the AWS provider.
# data "aws_availability_zone" "this" {
#   name = "us-east-1a"
# }






# variable "aws_region" {
#   description = "AWS Region to deploy resources."
#   type        = string
#   default     = "us-east-2"
# }

# variable "profile" {
#   description = "AWS CLI profile to use."
#   type        = string
#   default     = "dev-user1-PowerUserAccess"
# }

# variable "vpcs" {
#   description = "Map of VPC configurations keyed by unique identifier."
#   type = map(object({
#     vpc_cidr               = string
#     vpc_name               = string
#     subnet_bits            = number
#     public_subnets_number  = number
#     private_subnets_number = number
#     private_subnet_offset  = number
#   }))

#   default = {
#     vpc1 = {
#       vpc_cidr               = "10.0.0.0/16"
#       vpc_name               = "vpc-prod"
#       subnet_bits            = 8
#       public_subnets_number  = 3
#       private_subnets_number = 3
#       private_subnet_offset  = 32
#     },
#     vpc2 = {
#       vpc_cidr               = "10.1.0.0/16"
#       vpc_name               = "vpc-dev"
#       subnet_bits            = 8
#       public_subnets_number  = 3
#       private_subnets_number = 3
#       private_subnet_offset  = 32
#     },
#     # vpc3 = {
#     #   vpc_cidr               = "10.2.0.0/16"
#     #   vpc_name               = "vpc-xx"
#     #   subnet_bits            = 8
#     #   public_subnets_number  = 3
#     #   private_subnets_number = 3
#     #   private_subnet_offset  = 32
#     # },
#   }
# }

# variable "destination_cidr" {
#   description = "Destination CIDR for public route."
#   type        = string
#   default     = "0.0.0.0/0"
# }