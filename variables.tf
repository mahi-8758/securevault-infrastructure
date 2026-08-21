variable "aws_region" {
  description = "AWS region for future SecureVault resources."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name used by future resources."
  type        = string
  default     = "securevault"
}
