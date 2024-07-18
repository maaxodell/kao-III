output "base_api_url" {
  value = aws_api_gateway_deployment.api-deployment.invoke_url
}
