output "base_api_url" {
  value       = aws_api_gateway_deployment.api_deployment.invoke_url
  description = "The base API URL to point the Discord Developer API towards."
}
