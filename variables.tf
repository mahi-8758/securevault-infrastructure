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

variable "frontend_origin" {
  description = "Allowed browser origin for the SecureVault frontend."
  type        = string
  default     = "https://main.d3a1aca3sc3925.amplifyapp.com"
}

variable "allowed_origins" {
  description = "List of allowed browser origins for SecureVault frontend and S3 CORS."
  type        = list(string)
  default     = [
    "http://localhost:8080",
    "https://main.d3a1aca3sc3925.amplifyapp.com"
  ]
}
