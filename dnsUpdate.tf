# 获取根域名的 Route 53 Hosted Zone
data "aws_route53_zone" "root_zone" {
  name         = "dev.abmroseuan.me"
  private_zone = false
}

# 创建指向 ALB 的 A 记录
resource "aws_route53_record" "dev_abmroseuan_me" {
  zone_id = data.aws_route53_zone.root_zone.zone_id
  name    = "dev.abmroseuan.me"
  type    = "A"

  alias {
    name                   = aws_lb.webapp_alb.dns_name
    zone_id                = aws_lb.webapp_alb.zone_id
    evaluate_target_health = true
  }
}
