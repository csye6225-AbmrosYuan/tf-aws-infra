terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }


# test git work flow

# Configure the AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = var.profile
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Create a VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

# Create an Internet Gateway and attach it to the VPC
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}


# Create 3 public subnets (one per AZ)
resource "aws_subnet" "public" {
  count                   = var.public_subnets_number
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, var.subnet_bits, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-${data.aws_availability_zones.available.names[count.index]}"
  }
}


# Create 3 private subnets (one per AZ)
resource "aws_subnet" "private" {
  count  = var.private_subnets_number
  vpc_id = aws_vpc.this.id
  # Offset the index (using var.public_subnet_offset) to avoid overlapping with public subnets
  cidr_block        = cidrsubnet(var.vpc_cidr, var.subnet_bits, count.index + var.private_subnet_offset)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.vpc_name}-private-${data.aws_availability_zones.available.names[count.index]}"
  }
}


# Create a public route table and associate it with all public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = var.public_rt_name
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = var.destination_cidr
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public_assoc" {
  count          = var.public_subnets_number
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# Create a private route table and associate it with all private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = var.private_rt_name
  }
}

resource "aws_route_table_association" "private_assoc" {
  count          = var.private_subnets_number
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}





# terraform {
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#     }
#   }
# }

# provider "aws" {
#   region  = var.aws_region
#   profile = var.profile
# }

# # Get available AZs
# data "aws_availability_zones" "available" {
#   state = "available"
# }

# # Create VPCs and IGWs per VPC config
# resource "aws_vpc" "this" {
#   for_each = var.vpcs

#   cidr_block = each.value.vpc_cidr
#   enable_dns_support = true
#   enable_dns_hostnames = true

#   tags = {
#     Name = each.value.vpc_name
#   }
# }

# resource "aws_internet_gateway" "this" {
#   for_each = var.vpcs

#   vpc_id = aws_vpc.this[each.key].id

#   tags = {
#     Name = "${each.value.vpc_name}-igw"
#   }
# }

# # Flatten public and private subnet data
# locals {
#   public_subnets = flatten([
#     for vpc_key, vpc_config in var.vpcs : [
#       for idx in range(vpc_config.public_subnets_number) : {
#         vpc_key      = vpc_key
#         vpc_cidr     = vpc_config.vpc_cidr
#         subnet_bits  = vpc_config.subnet_bits
#         public_index = idx
#         vpc_name     = vpc_config.vpc_name
#         az           = data.aws_availability_zones.available.names[idx]
#       }
#     ]
#   ])

#   private_subnets = flatten([
#     for vpc_key, vpc_config in var.vpcs : [
#       for idx in range(vpc_config.private_subnets_number) : {
#         vpc_key        = vpc_key
#         vpc_cidr       = vpc_config.vpc_cidr
#         subnet_bits    = vpc_config.subnet_bits
#         private_index  = idx
#         vpc_name       = vpc_config.vpc_name
#         az             = data.aws_availability_zones.available.names[idx]
#         private_offset = vpc_config.private_subnet_offset
#       }
#     ]
#   ])
# }

# # Create public subnets
# resource "aws_subnet" "public" {
#   for_each = { for subnet in local.public_subnets : "${subnet.vpc_key}-${subnet.public_index}" => subnet }

#   vpc_id            = aws_vpc.this[each.value.vpc_key].id
#   cidr_block        = cidrsubnet(each.value.vpc_cidr, each.value.subnet_bits, each.value.public_index)
#   availability_zone = each.value.az
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "${each.value.vpc_name}-public-${each.value.az}"
#   }
# }

# # Create private subnets
# resource "aws_subnet" "private" {
#   for_each = { for subnet in local.private_subnets : "${subnet.vpc_key}-${subnet.private_index}" => subnet }

#   vpc_id     = aws_vpc.this[each.value.vpc_key].id
#   cidr_block = cidrsubnet(each.value.vpc_cidr, each.value.subnet_bits, each.value.private_index + each.value.private_offset)
#   availability_zone = each.value.az

#   tags = {
#     Name = "${each.value.vpc_name}-private-${each.value.az}"
#   }
# }

# # Create public route tables per VPC
# resource "aws_route_table" "public" {
#   for_each = var.vpcs

#   vpc_id = aws_vpc.this[each.key].id

#   tags = {
#     Name = "${each.value.vpc_name}-public-rt"
#   }
# }

# # Create default public routes
# resource "aws_route" "public_internet_access" {
#   for_each = var.vpcs

#   route_table_id         = aws_route_table.public[each.key].id
#   destination_cidr_block = var.destination_cidr
#   gateway_id             = aws_internet_gateway.this[each.key].id
# }

# # Associate public subnets with public route tables
# resource "aws_route_table_association" "public_assoc" {
#   for_each = { for key, subnet in aws_subnet.public : key => subnet }

#   subnet_id      = each.value.id
#   route_table_id = aws_route_table.public[split("-", each.key)[0]].id
# }

# # Create private route tables per VPC
# resource "aws_route_table" "private" {
#   for_each = var.vpcs

#   vpc_id = aws_vpc.this[each.key].id

#   tags = {
#     Name = "${each.value.vpc_name}-private-rt"
#   }
# }

# # Associate private subnets with private route tables
# resource "aws_route_table_association" "private_assoc" {
#   for_each = { for key, subnet in aws_subnet.private : key => subnet }

#   subnet_id      = each.value.id
#   route_table_id = aws_route_table.private[split("-", each.key)[0]].id
# }