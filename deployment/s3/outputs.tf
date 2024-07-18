output "s3_bucket_id" {
  value = aws_s3_bucket.lambda-bucket.id
}

output "s3_lambda-main-object-key" {
  value = aws_s3_object.lambda-main-zip.key
}
