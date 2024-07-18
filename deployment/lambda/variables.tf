variable "s3_bucket_id" {
  type        = string
  description = "The id of the S3 bucket that contains the archive of the Lambda function source code."
}

variable "s3_object_key" {
  type        = string
  description = "The name of the archive of the Lambda function source code."
}

variable "discord_public_api_key" {
  type        = string
  description = "My Discord Public API Key."
}
