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

variable "subnet_bits" {
  description = "Number of additional bits for subnetting from the VPC CIDR."
  type        = number
  default     = 8
}

variable "public_subnets_number" {
  description = "number of public subnet(s)"
  type        = number
  default     = 3
}

variable "private_subnets_number" {
  description = "number of private subnet(s)"
  type        = number
  default     = 3
}

variable "private_subnet_offset" {
  description = "Offset for calculating CIDR blocks of private subnets relative to public subnets."
  type        = number
  default     = 32
}

variable "destination_cidr" {
  default = "0.0.0.0/0"
}

variable "private_rt_name" {
  type    = string
  default = "vpc-private-rt"
}

variable "public_rt_name" {
  type    = string
  default = "vpc-public-rt"
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

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

resource "aws_subnet" "private" {
  count             = var.private_subnets_number
  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, var.subnet_bits, count.index + var.private_subnet_offset)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.vpc_name}-private-${data.aws_availability_zones.available.names[count.index]}"
  }
}

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
