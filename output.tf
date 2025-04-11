variable "config_bucket" {
  description = "The name of the long-term config bucket."
  type        = string
  # default     = "configbucket261447"
  default     = "configbucket261447demo"

}

variable "config_env_key" {
  description = "The key (object name) for the configuration file in the config bucket."
  type        = string
  default     = "webapp.env"
}



resource "aws_s3_object" "webapp_env" {
  bucket       = var.config_bucket
  key          = var.config_env_key
  content      = templatefile("${path.module}/webapp.env.tpl", {
    db_host        = split(":", aws_db_instance.rds_instance.endpoint)[0]
    s3_bucket_name = aws_s3_bucket.webappbucket.bucket
    s3_region_name = var.aws_region
    mysql_username = var.db_username
    mysql_password = random_password.db_password.result

    webapp_secret_key = jsondecode(data.aws_secretsmanager_secret_version.webapp_credentials_version.secret_string)["WEBAPP_SECRET_KEY"]
    webapp_aes_secret_key = jsondecode(data.aws_secretsmanager_secret_version.webapp_credentials_version.secret_string)["WEBAPP_AES_SECRET_KEY"]
    webapp_public_key = jsondecode(data.aws_secretsmanager_secret_version.webapp_credentials_version.secret_string)["WEBAPP_PUBLIC_KEY"]
    webapp_private_key = jsondecode(data.aws_secretsmanager_secret_version.webapp_credentials_version.secret_string)["WEBAPP_PRIVATE_KEY"]
  })
  content_type = "text/plain"
}



