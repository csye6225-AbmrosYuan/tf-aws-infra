

resource "local_file" "webapp_env" {
  content = templatefile("${path.module}/webapp.env.tpl", {
    db_host        = split(":",  aws_db_instance.rds_instance.endpoint)[0]
    # db_reader      = aws_db_instance.rds_read_replica.endpoint
    s3_bucket_name = "bucket${random_id.s3_bucket_id.hex}"
    s3_region_name = var.aws_region
  })
  filename = "${path.module}/webapp.env"
}