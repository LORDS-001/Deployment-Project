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

data "aws_s3_bucket" "website_bucket" {
  bucket = var.s3_website_bucket_name
}
resource "aws_cloudfront_origin_access_control" "website_oac" {
  name                              = "${var.s3_website_bucket_name}-oac"
  description                       = "OAC for S3 Website Origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
resource "aws_s3_bucket_policy" "website_policy" {
  bucket = data.aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.s3_oac_policy.json
}

data "aws_iam_policy_document" "s3_oac_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${data.aws_s3_bucket.website_bucket.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.website_cdn.arn]
    }
  }
}

resource "aws_cloudfront_distribution" "website_cdn" {

  provider = aws.acm_provider

  enabled         = true
  is_ipv6_enabled = true
  comment         = "CDN for ${var.domain_name}"

  origin {
    domain_name = data.aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = data.aws_s3_bucket.website_bucket.id

    s3_origin_config {
      origin_access_identity = "" 
    }

    origin_access_control_id = aws_cloudfront_origin_access_control.website_oac.id
  }

  default_cache_behavior {
    target_origin_id       = data.aws_s3_bucket.website_bucket.id
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = true

    cache_policy_id = "658327ea-f89d-4804-be3d-aa771c2fe45d"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }
  
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  aliases = [var.domain_name, "www.${var.domain_name}"]
  
  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    
  }
}