variable "lambda_invoke_arn" {
  type        = string
  description = "The invoke arn of the Lambda function to attach to the API."
}

variable "lambda_function_name" {
  type        = string
  description = "The name of the handler function of the Lambda function to attach to the API."
}
