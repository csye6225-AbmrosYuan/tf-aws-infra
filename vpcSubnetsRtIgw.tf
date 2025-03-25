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




variable "private_rt_name" {
  type    = string
  default = "vpc-private-rt"
}

variable "public_rt_name" {
  type    = string
  default = "vpc-public-rt"
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
