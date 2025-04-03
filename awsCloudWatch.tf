resource "aws_cloudwatch_log_group" "csye6225_log_group" {
  name              = "csye6225"
  retention_in_days = 7  # 设置日志保留天数，可根据需要调整
}

resource "aws_cloudwatch_log_stream" "webapp_log_stream" {
  name           = "webapp"
  log_group_name = aws_cloudwatch_log_group.csye6225_log_group.name
}




#add vpc endpoint for ec2 in private subnets
resource "aws_vpc_endpoint" "cloudwatch" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.monitoring"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.endpoint_sg.id]
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids        = aws_subnet.private[*].id
  security_group_ids = [aws_security_group.endpoint_sg.id]
}

resource "aws_security_group" "endpoint_sg" {
  name        = "endpoint_sg"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}