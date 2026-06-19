resource "aws_acm_certificate" "task_tracker_fastapi" {
  region = "us-east-1"
  domain_name = "${var.project.name}.${var.project.root_domain_name}"
  validation_method = "DNS"
}

resource "aws_acm_certificate_validation" "task_tracker_fastapi_validation" {
  region = "us-east-1"
  certificate_arn = aws_acm_certificate.task_tracker_fastapi.arn
  validation_record_fqdns = [
    for dvo in aws_acm_certificate.task_tracker_fastapi.domain_validation_options:
      dvo.resource_record_name
  ]
}

output "acm_domain_name" {
  value = aws_acm_certificate.task_tracker_fastapi.domain_name
}

output "acm_certificate_arn" {
  value = aws_acm_certificate.task_tracker_fastapi.arn
}

output "certificate_start" {
  value = aws_acm_certificate.task_tracker_fastapi.not_before
}

output "certificate_expiry" {
  value = aws_acm_certificate.task_tracker_fastapi.not_after
}

output "certificate_status" {
  value = aws_acm_certificate.task_tracker_fastapi.status
}

output "certificate_type" {
  value = aws_acm_certificate.task_tracker_fastapi.type
}

output "domain_validation_option_for_certificate" {
  value = aws_acm_certificate.task_tracker_fastapi.domain_validation_options
}
