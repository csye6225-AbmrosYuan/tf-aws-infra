# 获取根域名的 Route 53 Hosted Zone
variable "a_record_name" {
  description = "A record name"
  type        = string
  # default     = "dev.abmroseuan.me"
  default     = "demo.abmroseuan.me"
}

data "aws_route53_zone" "root_zone" {
  name         = var.a_record_name
  private_zone = false
}

# 创建指向 ALB 的 A 记录
resource "aws_route53_record" "dev_abmroseuan_me" {
  zone_id = data.aws_route53_zone.root_zone.zone_id
  name    = var.a_record_name
  type    = "A"

  alias {
    name                   = aws_lb.webapp_alb.dns_name
    zone_id                = aws_lb.webapp_alb.zone_id
    evaluate_target_health = true
  }
}
