output "s3_bucket_id" {
  value       = aws_s3_bucket.lambda_bucket.id
  description = "The id of the S3 bucket that contains the archive of the Lambda function source code."
}

output "s3_lambda_main_object_key" {
  value       = aws_s3_object.lambda_main_zip.key
  description = "The name of the archive of the Lambda function source code."
}
