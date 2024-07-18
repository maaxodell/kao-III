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

// Create Lambda function from our S3 object.
resource "aws_lambda_function" "main" {
  function_name = "main"
  role          = aws_iam_role.lambda_iam_role.arn

  s3_bucket = var.s3_bucket_id
  s3_key    = var.s3_object_key

  runtime = "nodejs20.x"
  handler = "index.handler"

  environment {
    variables = {
      PUBLIC_KEY = var.discord_public_api_key
    }
  }
}
