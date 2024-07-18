// Zip the lambda function's entire directory.
data "archive_file" "lambda_main" {
  type = "zip"

  source_dir  = "${path.module}/../../src/lambda/main"
  output_path = "${path.module}/../../bin/lambda_main.zip"
}

// Create an S3 Bucket for lambda function archives to be stored in.
// TODO: Versioning
resource "aws_s3_bucket" "lambda_bucket" {
}

// Upload the Lambda function archive to S3.
resource "aws_s3_object" "lambda_main_zip" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "lambda_main"
  source = data.archive_file.lambda_main.output_path
}
