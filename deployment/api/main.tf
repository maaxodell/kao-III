// Create REST API.
resource "aws_api_gateway_rest_api" "main" {
  name = "kao-the-third"
}

// Create resource (route) - greedy proxy route for Discord API.
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "{discord+}"
}

// Create proxy method.
resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

// Create Lambda integration, pointing it to both the proxy method and the Lambda function.
resource "aws_api_gateway_integration" "main-lambda-integration" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

// Create deployment resource.
resource "aws_api_gateway_deployment" "api-deployment" {
  depends_on = [
    aws_api_gateway_integration.main-lambda-integration
  ]

  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = "dev"
}

// Grant the API Permission to interact with the Lambda function.
resource "aws_lambda_permission" "api-to-lambda-permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

// Output the API URL after creation.
output "api_url" {
  value = aws_api_gateway_deployment.api-deployment.invoke_url
}
