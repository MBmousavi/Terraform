resource "aws_route53_zone" "zone" {
  name = var.route53_hosted_zone_name
  tags = { Terraform = "True" }
}


resource "aws_acm_certificate" "cert" {
  domain_name       = var.route53_hosted_zone_name
  subject_alternative_names = ["*.${var.route53_hosted_zone_name}"]
  validation_method = "DNS"
  tags              = { Terraform = "True"}

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.zone.zone_id
}

resource "aws_acm_certificate_validation" "acm_valid" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.acm : record.fqdn]
}

output "certificate_arn" {
  value = aws_acm_certificate.cert.arn
}
