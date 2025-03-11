

variable "aws_ami_id" {
  description = "ami id"
  type        = string
  default     = "ami-06c8c47568fea0864"
}


variable "aws_instance_type" {
  description = "instance type"
  type        = string
  default     =  "t2.micro"
}

variable "aws_instance_key_name" {
  description = "ssh key"
  type = string
  default = "csye6225"
}

variable "aws_volume_size" {
  type = number
  default = 25
}

variable "aws_volume_type" {
  type = string
  default = "gp2"
}

resource "aws_instance" "webapp_instance" {
  ami           = var.aws_ami_id  
  instance_type = var.aws_instance_type
  subnet_id     = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.webapp_sg.id]
  key_name = var.aws_instance_key_name

  root_block_device {
    volume_size = var.aws_volume_size  
    volume_type = var.aws_volume_type
    delete_on_termination = true  # 终止实例时删除卷
  }

  tags = {
    Name = "webapp-instance"
  }
}