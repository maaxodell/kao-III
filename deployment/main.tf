terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

// Create IAM role.
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "lambda_iam_role" {
  name               = "lambda_iam_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

// Zip the lambda function's entire directory.
data "archive_file" "lambda-main" {
  type = "zip"

  source_dir  = "${path.module}/../src/lambda/main"
  output_path = "${path.module}/../bin/lambda-main.zip"
}

// Create an S3 Bucket for lambda function archives to be stored in.
// TODO: Versioning
resource "aws_s3_bucket" "lambda-bucket" {
}

// Upload the Lambda function archive to S3.
resource "aws_s3_object" "lambda-main-zip" {
  bucket = aws_s3_bucket.lambda-bucket.id
  key    = "lambda-main"
  source = data.archive_file.lambda-main.output_path
}

// Load in Discord API Public Key using ASM.
data "aws_secretsmanager_secret" "discord-api-public-key" {
  arn = "arn:aws:secretsmanager:ap-southeast-2:211125624925:secret:kao-the-third/discord-public-key-8HhrB5"
}
data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.discord-api-public-key.id
}

// Create Lambda function from our S3 object.
resource "aws_lambda_function" "main" {
  function_name = "main"
  role          = aws_iam_role.lambda_iam_role.arn

  s3_bucket = aws_s3_bucket.lambda-bucket.id
  s3_key    = aws_s3_object.lambda-main-zip.key

  source_code_hash = data.archive_file.lambda-main.output_base64sha256

  runtime = "nodejs20.x"
  handler = "index.handler"

  environment {
    variables = {
      PUBLIC_KEY = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["PUBLIC_KEY"]
    }
  }
}

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
  uri                     = aws_lambda_function.main.invoke_arn
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
  function_name = aws_lambda_function.main.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

// Output the API URL after creation.
output "api_url" {
  value = aws_api_gateway_deployment.api-deployment.invoke_url
}
