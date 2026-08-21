provider "aws" {
  region = var.aws_region
}

locals {
  project_name = var.project_name
}
