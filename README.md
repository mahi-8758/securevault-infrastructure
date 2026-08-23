# SecureVault Infrastructure

SecureVault Infrastructure contains the complete Terraform Infrastructure as Code (IaC) configuration for provisioning SecureVault AWS serverless cloud infrastructure.

## Directory Tree

```text
securevault-infrastructure/
├── .gitignore               # Infrastructure gitignore (excludes terraform state, plans, zips, payloads)
├── apigateway.tf            # API Gateway REST API, CORS options, Cognito Authorizer, routes, & Lambda integrations
├── cognito.tf               # AWS Cognito User Pool & User Pool Client configuration
├── dynamodb.tf              # DynamoDB tables (Metadata Table & Audit Logs Table with GSI ownerId-index)
├── iam.tf                   # IAM execution roles & inline policies for Lambda functions (S3 & DynamoDB access)
├── lambda.tf                # AWS Lambda function definitions, environment variables, & package sources
├── main.tf                  # AWS Provider & Terraform configuration
├── outputs.tf               # Infrastructure outputs (API Endpoint, Cognito Pool ID, Client ID, Bucket Name)
├── README.md                # Infrastructure documentation
├── s3.tf                    # S3 bucket, CORS configuration, KMS encryption, & public access blocks
├── variables.tf             # Configurable input variables (AWS Region, project name, environment name)
└── versions.tf              # Terraform & AWS provider version constraints
```

## Provisioned AWS Resources

1. **Authentication (`cognito.tf`)**:
   - `aws_cognito_user_pool.main`: Secure user pool supporting email-based signup/login and verification.
   - `aws_cognito_user_pool_client.app`: Client application integration for browser authentication.

2. **Document Storage (`s3.tf`)**:
   - `aws_s3_bucket.files`: Encrypted S3 bucket for user documents.
   - `aws_s3_bucket_server_side_encryption_configuration`: Enforces SSE-KMS encryption (`aws:kms`).
   - `aws_s3_bucket_cors_configuration`: Enables CORS headers (`GET`, `PUT`, `DELETE`, `POST`, `OPTIONS`) for direct browser transfers.
   - `aws_s3_bucket_public_access_block`: Enforces strict public access block settings.

3. **Database Tables (`dynamodb.tf`)**:
   - `aws_dynamodb_table.metadata`: Table storing document metadata (`fileId`, `ownerId`, `fileName`, `s3Key`, `size`, `uploadedAt`, `status`). Includes `ownerId-index` Global Secondary Index (GSI).
   - `aws_dynamodb_table.audit_logs`: Table recording security audit events (`logId`, `ownerId`, `fileId`, `action`, `timestamp`, `ipAddress`). Includes `ownerId-index` GSI.

4. **Serverless Execution (`lambda.tf` & `iam.tf`)**:
   - `aws_iam_role.lambda_exec`: IAM execution role with least-privilege policies for CloudWatch Logs, DynamoDB query/put/delete, and S3 get/put/delete.
   - **Lambda Functions**:
     - `upload`: POST `/upload`
     - `files`: GET `/files` and GET `/files/{fileId}`
     - `download`: GET `/download/{fileId}`
     - `audit`: GET `/audit`
     - `delete`: DELETE `/files/{fileId}`

5. **API Gateway (`apigateway.tf`)**:
   - `aws_api_gateway_rest_api.api`: REST API gateway routing frontend requests to Lambda handlers.
   - `aws_api_gateway_authorizer.cognito`: Protects endpoints using Cognito User Pool JWT verification.
   - Full CORS preflight `OPTIONS` handlers configured across all endpoints.

## Deployment Instructions

### Prerequisites
- Install [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) (>= 1.0.0).
- Configure AWS credentials using AWS CLI (`aws configure`) or environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`).
- Build production Lambda packages in `securevault-backend` first (`npm run build:lambda`).

### Steps
1. Navigate to the infrastructure folder:
   ```bash
   cd securevault-infrastructure
   ```
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Validate configuration:
   ```bash
   terraform validate
   ```
4. Preview plan:
   ```bash
   terraform plan
   ```
5. Apply and provision AWS resources:
   ```bash
   terraform apply
   ```

## Infrastructure Outputs

After `terraform apply` completes, the following output parameters will be displayed:

- **`api_endpoint`**: The base API Gateway URL to configure in `securevault-frontend/js/config.js`.
- **`user_pool_id`**: The AWS Cognito User Pool ID.
- **`user_pool_client_id`**: The AWS Cognito App Client ID.
- **`s3_bucket_name`**: The provisioned S3 Bucket name.
