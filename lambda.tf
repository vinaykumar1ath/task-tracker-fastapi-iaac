resource "aws_iam_role" "task_tracker_fastapi" {
  name = "${var.project.name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "task_tracker_fastapi" {
  role       = aws_iam_role.task_tracker_fastapi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

output "lambda_execution_role_arn" {
  value = aws_iam_role.task_tracker_fastapi.arn
}

resource "aws_lambda_function" "task_tracker_fastapi" {
  region        = var.project.region
  function_name = "${var.project.name}-lambda"
  role          = aws_iam_role.task_tracker_fastapi.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.task_tracker_fastapi.repository_url}:latest"
  memory_size   = 512
  timeout       = 30

  environment {
    variables = {
      DB_URL      = var.task_tracker_fastapi_env.DB_URL
      JWT_SECRET  = var.task_tracker_fastapi_env.JWT_SECRET
    }
  }

}

output "lambda_arn" {
  value = aws_lambda_function.task_tracker_fastapi.arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.task_tracker_fastapi.invoke_arn
}

output "lambda_function_name" {
  value = aws_lambda_function.task_tracker_fastapi.function_name
}
