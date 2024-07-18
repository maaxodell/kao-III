output "invoke_arn" {
  value       = aws_lambda_function.main.invoke_arn
  description = "The invoke arn to pass to the API gateway."
}

output "function_name" {
  value       = aws_lambda_function.main.function_name
  description = "The function handler name to pass to the API gateway."
}
