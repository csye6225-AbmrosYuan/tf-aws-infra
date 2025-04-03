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

variable "webapp_env_dest_dir" {
  type    = string
  default = "/tmp/webapp.env"
}

variable "cloud_watch_json_local_path" {
  type    = string
  default = "cloud_watch_agent.json"
}

variable "cloud_watch_json_dest_dir" {
  type    = string
  default = "/tmp/cloud_watch_agent.json"
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

  provisioner "file" {
    source      = local_file.webapp_env.filename
    destination = var.webapp_env_dest_dir
  }

  provisioner "file" {
    source      = var.cloud_watch_json_local_path
    destination = var.cloud_watch_json_dest_dir
  }

  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo mv -f /tmp/webapp.env /opt/csye6225/webappFlask/app/",
  #     "sudo chown csye6225_user:csye6225 /opt/csye6225/webappFlask/app/webapp.env",
  #     "sudo mv -f /tmp/cloud_watch_agent.json /opt/csye6225/webappFlask/config/cloud_watch_agent.json",
  #     "sudo chown csye6225_user:csye6225 /opt/csye6225/webappFlask/config/cloud_watch_agent.json",
  #     "sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/csye6225/webappFlask/config/cloud_watch_agent.json -s",
  #     "sudo systemctl enable amazon-cloudwatch-agent",
  #     "sudo systemctl enable webappFlask",
  #     "sudo systemctl start webappFlask.service"
  #   ]
  # }

  root_block_device {
    volume_size           = var.aws_volume_size  
    volume_type           = var.aws_volume_type
    delete_on_termination = true 
  }

  tags = {
    Name = "webapp-instance"
  }
}
