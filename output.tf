variable "config_bucket" {
  description = "The name of the long-term config bucket."
  type        = string
  default     = "configbucket261447"
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
  })
  content_type = "text/plain"
}



