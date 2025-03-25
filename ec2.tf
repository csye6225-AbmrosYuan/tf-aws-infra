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

# variable "webapp_env" {
#   type = string
#   default = "webapp.env"
# }
variable "destination_dir" {
  type = string
  default = "/tmp/webapp.env"
}

variable "ec2_ssh_user" {
  type = string
  default = "ubuntu"
}

# variable "ec2_ssh_key" {
#   description = "Path to the SSH private key file"
#   type        = string
#   default     = null
# }

# locals {
#   ssh_key_path = var.ec2_ssh_key != null ? var.ec2_ssh_key : "${path.module}/csye6225.pem"
# }


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
    source      = local_file.webapp_env.filename
    destination = var.destination_dir

    connection {
      type        = "ssh"
      user        = var.ec2_ssh_user
      private_key = file("${path.module}/csye6225.pem")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv -f /tmp/webapp.env /opt/csye6225/webappFlask/app/",
      "sudo chown csye6225_user:csye6225 /opt/csye6225/webappFlask/app/webapp.env"
    ]

    connection {
      type        = "ssh"
      user        = var.ec2_ssh_user
      private_key = file("${path.module}/csye6225.pem")
      host        = self.public_ip
    }
  }

  root_block_device {
    volume_size = var.aws_volume_size  
    volume_type = var.aws_volume_type
    delete_on_termination = true 
  }

  tags = {
    Name = "webapp-instance"
  }
}


# EC2 IAM policy
resource "aws_iam_policy" "webapp_policy" {
  name        = "webapp_policy"
  description = "Policy for webapp user with S3 and EC2 permissions"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ObjectOperations",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = "${aws_s3_bucket.webappbucket.arn}/*"
      },
      {
        Sid    = "Statement1",
        Effect = "Allow",
        Action = [
          "ec2:AssociateRouteTable",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:CreateRouteTable",
          "ec2:CreateSecurityGroup",
          "ec2:CreateSubnet",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:RevokeSecurityGroupEgress"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach policy to webapp
resource "aws_iam_user_policy_attachment" "webapp_policy_attachment" {
  user       = "webapp"
  policy_arn = aws_iam_policy.webapp_policy.arn
}