output "project_name" {
  description = "Configured project name."
  value       = local.project_name
}

output "aws_region" {
  description = "Configured AWS region."
  value       = var.aws_region
}

output "user_pool_id" {
  description = "ID of the Cognito user pool used by SecureVault users."
  value       = aws_cognito_user_pool.users.id
}

output "user_pool_client_id" {
  description = "ID of the browser app client for the SecureVault Cognito user pool."
  value       = aws_cognito_user_pool_client.web.id
}

output "api_gateway_url" {
  description = "Base URL for the SecureVault API Gateway dev stage."
  value       = "https://${aws_api_gateway_rest_api.securevault.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.dev.stage_name}"
}

output "s3_files_bucket_name" {
  description = "Name of the private S3 bucket used for SecureVault files."
  value       = aws_s3_bucket.files.bucket
}

output "s3_files_bucket_arn" {
  description = "ARN of the private S3 bucket used for SecureVault files."
  value       = aws_s3_bucket.files.arn
}
