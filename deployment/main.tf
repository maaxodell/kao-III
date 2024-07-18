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

module "asm" {
  source = "./asm"
}

// Needs S3 bucket (id) and object (key) from s3, discord token from asm.
module "lambda" {
  source                 = "./lambda"
  s3_bucket_id           = module.s3.s3_bucket_id
  s3_object_key          = module.s3.s3_lambda_main_object_key
  discord_public_api_key = module.asm.discord_public_api_key
}

// Needs zip archive of lambda.
module "s3" {
  source = "./s3"
}

module "api" {
  source               = "./api"
  lambda_invoke_arn    = module.lambda.invoke_arn
  lambda_function_name = module.lambda.function_name
}
