data "aws_cloudfront_cache_policy" "optimized" {
  name = "Managed-CachingOptimized"
}

/* 
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
*/

/*
resource "aws_route53_zone" "primary" {
  name = "lords.com"

  tags = {
    Name = "lords.com Website"
  }
}
*/
/*
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.website_cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = aws_route53_zone.primary.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  zone_id         = each.value.zone_id
  records         = [each.value.record]
}
*/

/*
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.website_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  provider = aws.acm_provider
}
*/

/*
data "aws_s3_bucket" "website_bucket" {
  bucket = var.s3_website_bucket_name
}
*/

resource "aws_cloudfront_origin_access_control" "website_oac" {
  name                              = "${var.s3_website_bucket_name}-oac"
  description                       = "OAC for S3 Website Origin"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
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
      "${aws_s3_bucket.website_bucket.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.website_cdn.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "website_policy" {
  depends_on = [
    aws_cloudfront_distribution.website_cdn
  ]
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipalReadOnly"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.website_cdn.arn
          }
        }
      }
    ]
  })
}


resource "aws_cloudfront_distribution" "website_cdn" {

  # provider = aws.acm_provider

  enabled         = true
  is_ipv6_enabled = true
  comment         = "CDN for ${var.domain_name}"

  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = "S3-Website-Origin"

    /*
    s3_origin_config {
      origin_access_identity = "" 
    }
    */

    origin_access_control_id = aws_cloudfront_origin_access_control.website_oac.id
  }

  default_cache_behavior {
    target_origin_id       = "S3-Website-Origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = true

    cache_policy_id = data.aws_cloudfront_cache_policy.optimized.id
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

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  /*
  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }
  */
}

/*
resource "aws_route53_record" "root_record" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.domain_name  
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.website_cdn.hosted_zone_id
    evaluate_target_health = true
  }
}
*/

/*
resource "aws_route53_record" "www_record" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.${var.domain_name}" 
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.website_cdn.hosted_zone_id
    evaluate_target_health = true
  }
}
*/

output "website_url" {
  description = "The URL of the website"
  value       = "https://${aws_cloudfront_distribution.website_cdn.domain_name}"
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.website_cdn.id
}