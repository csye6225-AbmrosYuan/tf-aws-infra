resource "aws_cloudwatch_log_group" "csye6225_log_group" {
  name              = "csye6225"
  retention_in_days = 7  # 设置日志保留天数，可根据需要调整
}

resource "aws_cloudwatch_log_stream" "webapp_log_stream" {
  name           = "webapp"
  log_group_name = aws_cloudwatch_log_group.csye6225_log_group.name
}
