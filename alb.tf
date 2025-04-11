# sg for Load Balancer
resource "aws_security_group" "lb_sg" {
  name        = "load_balancer_sg"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.this.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "load_balancer_sg"
  }
}

# sg for webapp ec2
resource "aws_security_group" "webapp_sg" {
  name        = "webapp_sg"
  description = "Security group for web application instances"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "webapp_sg"
  }
}



#Create Application load balancer
resource "aws_lb" "webapp_alb" {
  name               = "webapp-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "webapp-alb"
  }
}

# LB target group
resource "aws_lb_target_group" "webapp_tg" {
  name     = "webapp-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id

  health_check {
    path                = "/healthz"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "webapp-tg"
  }
}

#LB Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.webapp_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_tg.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.webapp_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn  = data.aws_acm_certificate.abmroseuan_cert.arn
  certificate_arn   = "arn:aws:acm:us-east-1:980921725983:certificate/b2eebe6d-4f09-47f4-8ec7-3edbe9bc757d"


  default_action {
    type = "fixed-response"
    fixed_response {
      content_type  = "text/plain"  # 设置响应内容类型
      message_body  = "OK"
      status_code   = 200
    }
  }
}

# variable "domain_name" {
#   type = string
#   default = "abmroseuan.me"
# }

# data "aws_acm_certificate" "abmroseuan_cert" {
#   provider = aws.acm
#   domain   = var.domain_name 
#   statuses = ["ISSUED"]
#   most_recent = true
# }
