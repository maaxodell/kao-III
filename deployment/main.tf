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
// TODO: Move to using S3 Bucket instead of zip archive approach. 
data "archive_file" "lambda-main" {
  type = "zip"

  source_dir  = "${path.module}/../src/lambda/main"
  output_path = "${path.module}/../bin/lambda-main.zip"
}

// Create Lambda function from zip archive.
resource "aws_lambda_function" "main" {
  function_name = "main"
  filename      = "${path.module}/../bin/lambda-main.zip"
  role          = aws_iam_role.lambda_iam_role.arn

  source_code_hash = data.archive_file.lambda-main.output_base64sha256

  runtime = "nodejs20.x"
  handler = "index.handler"
}

// Create a CloudWatch log group.
resource "aws_cloudwatch_log_group" "main" {
  name = "/aws/lambda/${aws_lambda_function.main.function_name}"

  retention_in_days = 7
}
