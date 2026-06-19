resource "aws_apigatewayv2_api" "task_tracker_fastapi" {
  region = var.project.region
  name = "${var.project.name}-apigateway"
  protocol_type = "HTTP"
}

resource "aws_lambda_permission" "task_tracker_fastapi_apigateway" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.task_tracker_fastapi.arn
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.task_tracker_fastapi.execution_arn}/*/*/*"
}

resource "aws_apigatewayv2_stage" "task_tracker_fastapi"{
  name = "$default"
  api_id = aws_apigatewayv2_api.task_tracker_fastapi.id
  auto_deploy = true
}

output "apigateway_id" {
  value = aws_apigatewayv2_api.task_tracker_fastapi.id
}

output "apigateway_api_endpoint" {
  value = aws_apigatewayv2_api.task_tracker_fastapi.api_endpoint
}

output "apigateway_arn" {
  value = aws_apigatewayv2_api.task_tracker_fastapi.arn
}

output "apigateway_default_stage_invoke_url" {
  value = aws_apigatewayv2_stage.task_tracker_fastapi.invoke_url
}

resource "aws_apigatewayv2_integration" "task_tracker_fastapi" {
  api_id = aws_apigatewayv2_api.task_tracker_fastapi.id
  integration_type = "AWS_PROXY"
  connection_type = "INTERNET"
  integration_uri = aws_lambda_function.task_tracker_fastapi.invoke_arn
  timeout_milliseconds = 5000
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "task_tracker_fastapi_main" {
  api_id    = aws_apigatewayv2_api.task_tracker_fastapi.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.task_tracker_fastapi.id}"
}

