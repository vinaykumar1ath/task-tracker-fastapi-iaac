resource "aws_cloudfront_origin_access_control" "task_tracker_fastapi_default_oac" {
  name = "${var.project.name}-default-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}

data "aws_cloudfront_cache_policy" "s3_optimized" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "apigateway_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "allow_cookies" {
  name = "Managed-AllViewerExceptHostHeader"
}

resource "aws_cloudfront_distribution" "task_tracker_fastapi" {
  origin {
    origin_id = "${var.project.name}-cloudfront-origin-s3"
    origin_access_control_id = aws_cloudfront_origin_access_control.task_tracker_fastapi_default_oac.id
    domain_name = aws_s3_bucket.task_tracker_fastapi.bucket_regional_domain_name
  }

  origin {
    origin_id = "${var.project.name}-cloudfront-origin-apigateway"
    domain_name = replace(replace(aws_apigatewayv2_stage.task_tracker_fastapi.invoke_url, "https://", ""), "/","")
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "match-viewer"
      origin_keepalive_timeout = 30
      origin_ssl_protocols = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods = ["HEAD", "POST", "GET", "PUT", "PATCH", "DELETE", "OPTIONS", "HEAD"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id =  "${var.project.name}-cloudfront-origin-s3"
    viewer_protocol_policy = "allow-all"
    cache_policy_id = data.aws_cloudfront_cache_policy.s3_optimized.id
    default_ttl = 1500
    max_ttl = 86400
    min_ttl = 0
  }

  ordered_cache_behavior {
    path_pattern = "/auth*"
    allowed_methods = ["HEAD", "POST", "GET", "PUT", "PATCH", "DELETE", "OPTIONS"]
    cached_methods = ["HEAD", "GET", "OPTIONS"]
    target_origin_id = "${var.project.name}-cloudfront-origin-apigateway"
    cache_policy_id = data.aws_cloudfront_cache_policy.apigateway_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.allow_cookies.id
    default_ttl = 60
    max_ttl = 300
    min_ttl = 0
    viewer_protocol_policy = "allow-all"
  }

  ordered_cache_behavior {
    path_pattern = "/task*"
    allowed_methods = ["HEAD", "POST", "GET", "PUT", "PATCH", "DELETE", "OPTIONS"]
    cached_methods = ["HEAD", "GET", "OPTIONS"]
    target_origin_id = "${var.project.name}-cloudfront-origin-apigateway"
    cache_policy_id = data.aws_cloudfront_cache_policy.apigateway_disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.allow_cookies.id
    default_ttl = 60
    max_ttl = 300
    min_ttl = 0
    viewer_protocol_policy = "allow-all"
  }


  default_root_object = "index.html"
  enabled = true
  is_ipv6_enabled = true
  price_class = "PriceClass_200"
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations = ["IN", "US", "CA"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.task_tracker_fastapi.arn
    ssl_support_method = "sni-only"
  }
  aliases = ["${var.project.name}.${var.project.root_domain_name}"]
}

data "aws_iam_policy_document" "cloudfront_s3_access" {
  statement {
    sid = "AllowS3AccessToCloudfront"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.task_tracker_fastapi.arn}/*",
    ]
    condition {
      test = "StringEquals"
      variable = "AWS:SourceArn"
      values = [aws_cloudfront_distribution.task_tracker_fastapi.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "task_tracker_fastapi_cloudfront" {
  bucket = aws_s3_bucket.task_tracker_fastapi.bucket
  policy = data.aws_iam_policy_document.cloudfront_s3_access.json
}

output "cloudfront_arn" {
  value = aws_cloudfront_distribution.task_tracker_fastapi.arn
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.task_tracker_fastapi.domain_name
}
