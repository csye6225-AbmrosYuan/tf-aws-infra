variable "aws_ami_id" {
  description = "ami id"
  type        = string
  # default     = "ami-08842739f1865373e"
  default     = "ami-03f3b9b34004ec885"
}

variable "aws_instance_type" {
  description = "instance type"
  type        = string
  default     = "t2.micro"
}

variable "aws_instance_key_name" {
  description = "ssh key"
  type        = string
  # default     = "csye6225"
  default     = "csye6225demo"

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

# sg for webapp ec2
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Security group for web application instances"
  vpc_id      = aws_vpc.this.id


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
    Name = "bastion_sg"
  }
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
  # subnet_id              = aws_subnet.public[0].id
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  connection {
    type        = "ssh"
    user        = var.ec2_ssh_user
    # private_key = file("${path.module}/csye6225.pem")
    private_key = file("${path.module}/csye6225demo.pem")
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
    Name = "bastion"
  }
}
