variable "aws_ami_id" {
  description = "ami id"
  type        = string
  default     = "ami-097f2882242e0a1c9"
}

variable "aws_instance_type" {
  description = "instance type"
  type        = string
  default     = "t2.micro"
}

variable "aws_instance_key_name" {
  description = "ssh key"
  type        = string
  default     = "csye6225"
}

variable "aws_volume_size" {
  type    = number
  default = 25
}

variable "aws_volume_type" {
  type    = string
  default = "gp2"
}

variable "ec2_user_data" {
  type    = string
  default = "ec2SetUp.sh"
}

variable "ec2_ssh_user" {
  type    = string
  default = "ubuntu"
}

# 创建 Instance Profile，将 ec2_instance_role 与 EC2 实例关联
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_instance_role.name
}

resource "aws_instance" "webapp_instance" {
  ami                    = var.aws_ami_id  
  instance_type          = var.aws_instance_type
  key_name               = var.aws_instance_key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  user_data              = file(var.ec2_user_data)
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.webapp_sg.id]

  connection {
    type        = "ssh"
    user        = var.ec2_ssh_user
    private_key = file("${path.module}/csye6225.pem")
    host        = self.public_ip
  }

  # 移除原来通过 provisioner 传递文件的部分：
  # provisioner "file" { ... }

  root_block_device {
    volume_size           = var.aws_volume_size  
    volume_type           = var.aws_volume_type
    delete_on_termination = true 
  }

  tags = {
    Name = "webapp-instance"
  }
}
