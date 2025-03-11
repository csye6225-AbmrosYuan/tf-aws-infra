terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
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
