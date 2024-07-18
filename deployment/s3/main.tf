// Zip the lambda function's entire directory.
data "archive_file" "lambda-main" {
  type = "zip"

  source_dir  = "${path.module}/../../src/lambda/main"
  output_path = "${path.module}/../../bin/lambda-main.zip"
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
