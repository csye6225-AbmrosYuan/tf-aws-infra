resource "aws_security_group" "webapp_sg" {
  name        = "webapp-sg"
  description = "Security group for web application EC2 instances"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" 
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "webapp-sg"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "rdb_security_group"
  description = "Security group for RDS instances"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port       = 3306  
    to_port         = 3306  
    protocol        = "tcp"
    security_groups = [aws_security_group.webapp_sg.id]
    description     = "Allow database access from application security group"
  }
}
