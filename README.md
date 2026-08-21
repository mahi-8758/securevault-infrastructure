# SecureVault Infrastructure

Terraform foundation for the future SecureVault AWS architecture. This initial phase only configures the AWS provider, region, and project variables; it provisions no AWS resources.

## Authentication

Authenticate Terraform through the AWS CLI, an AWS profile, or environment-based credentials. Do not put access keys or secret keys in Terraform files, variable files, or source control.

## Checks

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

The initial plan should contain no resource changes.

## Future phases

Later phases can add Cognito, S3, DynamoDB, IAM, Lambda, API Gateway, CloudFront, and KMS in separately reviewed steps. This repository remains Terraform-only.
