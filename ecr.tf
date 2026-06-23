resource "aws_ecr_repository" "task_tracker_fastapi" {
  region = var.project.region
  name   = "${var.project.name}/${var.project.name}-backend"
  force_delete = true
  image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"
  image_tag_mutability_exclusion_filter {
    filter = "latest*"
    filter_type = "WILDCARD"
  }

  provisioner "local-exec" {
    command = <<-EOT
      docker pull public.ecr.aws/lambda/provided:latest
      docker tag public.ecr.aws/lambda/provided:latest ${self.repository_url}:latest
      docker push ${self.repository_url}:latest
    EOT
  }
}

output "ecr_repo_arn" {
  value = aws_ecr_repository.task_tracker_fastapi.arn
}

output "ecr_repo_url" {
  value = aws_ecr_repository.task_tracker_fastapi.repository_url
}
