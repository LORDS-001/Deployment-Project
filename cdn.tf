resource "aws_acm_certificate" "website_cert" {
  domain_name       = "lords.com"        
  validation_method = "DNS"

  subject_alternative_names = [
    "www.lords.com"          
  ]

  provider = aws.acm_provider 

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "primary" {
  name         = "lords.com."     
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.website_cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.primary.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  zone_id         = each.value.zone_id
  records         = [each.value.record]
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.website_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  provider = aws.acm_provider
}