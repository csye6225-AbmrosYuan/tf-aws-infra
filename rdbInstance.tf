variable "db_identifier" {
  description = "The RDS instance identifier"
  type        = string
  default     = "webapprdb"
}

variable "db_engine" {
  description = "The database engine to use"
  type        = string
  default     = "mysql"  # 可选值："mysql"、"mariadb"、"postgres"
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "db_username" {
  description = "The master username for the database"
  type        = string
  default     = "root"
}

# variable "db_password" {
#   description = "The master password for the database"
#   type        = string
#   default     = "12345678"
# }

variable "db_name" {
  description = "The name of the database to create"
  type        = string
  default     = "webapp_db"
}

variable "publicly_accessible" {
  description = "Whether the RDS instance is publicly accessible"
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip taking a final DB snapshot before deletion"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default = {
    Name = "csye6225_webapp_rdb"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "RDS Subnet Group"
  }
}

resource "aws_db_instance" "rds_instance" {
  identifier             = var.db_identifier
  engine                 = var.db_engine
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  publicly_accessible    = var.publicly_accessible
  multi_az               = var.multi_az
  skip_final_snapshot    = var.skip_final_snapshot
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  parameter_group_name   = aws_db_parameter_group.mysql_pg.name
  username               = var.db_username
  # password               = var.db_password
  password               = random_password.db_password.result

  storage_encrypted      = true
  kms_key_id             = data.aws_kms_key.rds_key.arn

  db_name                = var.db_name
  tags                   = var.tags
}
