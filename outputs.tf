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
