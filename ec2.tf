variable "aws_ami_id" {
  description = "ami id"
  type        = string
  default     = "ami-038162d1d15a62337"
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

variable "ec2_user_data" {
  type = string
  default = "ec2SetUp.sh"
}

variable "webapp_env" {
  type = string
  default = "webapp.env"
}
variable "destination_dir" {
  type = string
  default = "/opt/csye6225/webappFlask/app"
}

variable "ec2_ssh_user" {
  type = string
  default = "ubuntu"
}

variable "ec2_ssh_key" {
  description = "Path to the SSH private key file"
  type        = string
  default     = null
}

locals {
  ssh_key_path = var.ec2_ssh_key != null ? var.ec2_ssh_key : "${path.module}/csye6225.pem"
}


resource "aws_instance" "webapp_instance" {
  ami           = var.aws_ami_id  
  instance_type = var.aws_instance_type
  key_name = var.aws_instance_key_name

  #set user data
  user_data = file(var.ec2_user_data)

  subnet_id     = aws_subnet.public[0].id

  #set security group
  vpc_security_group_ids = [aws_security_group.webapp_sg.id]

  #  将本地的 setup.sh 文件传输到实例的 /opt/ 目录
  provisioner "file" {
    source      = var.webapp_env
    destination = var.destination_dir

    connection {
      type        = "ssh"
      user        = var.ec2_ssh_user
      private_key = var.ec2_ssh_key
      host        = self.public_ip
    }
  }

  root_block_device {
    volume_size = var.aws_volume_size  
    volume_type = var.aws_volume_type
    delete_on_termination = true  # 终止实例时删除卷
  }

  tags = {
    Name = "webapp-instance"
  }
}