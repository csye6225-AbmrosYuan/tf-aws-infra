# random db secret id
resource "random_id" "db_secret_id" {
  byte_length = 8
}

resource "random_password" "db_password" {
  length  = 16           
  special = true         
  upper   = true         
  lower   = true         
  numeric = true       
}


# create a new secret in SM
resource "aws_secretsmanager_secret" "db_secrets" {
  name        = "db_secrets${random_id.db_secret_id.hex}"
  description = "Database credentials including username, password, and host URL"
  tags = {
    Environment = "Production"
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id     = aws_secretsmanager_secret.db_secrets.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    host_url = split(":", aws_db_instance.rds_instance.endpoint)[0]
  })
}

data "aws_secretsmanager_secret" "webapp_credentials" {
  name = "webappCredentials"  
}

# get secret version
data "aws_secretsmanager_secret_version" "webapp_credentials_version" {
  secret_id = data.aws_secretsmanager_secret.webapp_credentials.id
}


# 获取 EC2 密钥
data "aws_kms_key" "ec2_key" {
  key_id = "alias/EC2-key"
}

# 获取 S3 密钥
data "aws_kms_key" "s3_key" {
  key_id = "alias/S3-key"
}

# 获取 RDS 密钥
data "aws_kms_key" "rds_key" {
  key_id = "alias/RDS-key"
}

# 获取 Secrets Manager 密钥
data "aws_kms_key" "secrets_manager_key" {
  key_id = "alias/SecretManager-key"
}
