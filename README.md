# ☁️ SecureVault Infrastructure

SecureVault Infrastructure contains the complete Terraform Infrastructure as Code (IaC) configuration for provisioning and managing the cloud resources for the SecureVault platform on AWS. Using declarative HCL (HashiCorp Configuration Language), this repository provisions user authentication services, REST API endpoints, serverless compute handlers, private document storage, structured database tables, and security IAM execution roles.

---

## 🎥 Project Demo

▶️ [Watch SecureVault Project Demo](https://youtu.be/W42Mjil9OKo)

This video demonstrates the complete working SecureVault application and its deployed cloud architecture.

---

## 🏗️ AWS Architecture

The infrastructure deploys a fully serverless, highly available cloud architecture:

```text
User / Browser Frontend
  ↓
Amazon Cognito (User Pool & Web Client)
  ↓
Amazon API Gateway (REST API & Cognito Authorizer)
  ↓
AWS Lambda Functions (Node.js 20.x Handlers)
  ├──→ Amazon S3 Bucket (AES256 SSE, CORS, Versioning, Public Access Block)
  └──→ Amazon DynamoDB Tables
             ├── FileMetadata Table (Primary Key: fileId, GSI: ownerId-index)
             └── AccessLogs Table (Primary Key: fileId, Sort Key: timestamp, GSI: ownerId-index)
```

---

## ✨ Provisioned AWS Resources

### 1. User Authentication (`cognito.tf`)
- **`aws_cognito_user_pool.users`**: Manages user identities with email-based authentication, automated verification, and strong password policy enforcement.
- **`aws_cognito_user_pool_client.web`**: App client configured for web browser authentication without client secret requirement, supporting SRP, direct password, and refresh token authorization flows.

### 2. API Gateway & Routing (`apigateway.tf`)
- **`aws_api_gateway_rest_api.securevault`**: Regional REST API gateway routing frontend requests.
- **`aws_api_gateway_authorizer.securevault`**: Cognito User Pools authorizer protecting API routes by validating JWT Bearer tokens.
- **Endpoints & Integrations**: Configures routes for `/upload` (POST), `/files` (GET), `/files/{fileId}` (GET, DELETE), `/download/{fileId}` (GET), and `/audit` (GET) with AWS_PROXY Lambda integrations.
- **CORS Handling**: Full mock preflight `OPTIONS` method integrations, responses, and headers for browser cross-origin requests.
- **Deployment Stage**: `aws_api_gateway_stage.dev` deploying the API configuration to the `dev` stage.

### 3. Serverless Compute & Security (`lambda.tf` & `iam.tf`)
- **Lambda Functions**: Provisioned Node.js 20.x runtime execution functions (`securevault-upload`, `securevault-files`, `securevault-download`, `securevault-delete`, `securevault-audit`).
- **`aws_iam_role.securevault_lambda_role`**: Execution role assumed by AWS Lambda services.
- **IAM Policies**: Attaches `AWSLambdaBasicExecutionRole` for CloudWatch logging and custom inline policy granting scoped access to DynamoDB tables/indexes and S3 bucket objects.

### 4. Cloud Storage (`s3.tf`)
- **`aws_s3_bucket.files`**: Private S3 bucket named `securevault-files-<account_id>` for document storage.
- **`aws_s3_bucket_public_access_block.files`**: Enforces strict public access block parameters.
- **`aws_s3_bucket_server_side_encryption_configuration.files`**: Enforces default AES256 server-side encryption.
- **`aws_s3_bucket_versioning.files`**: Enables object versioning for data protection.
- **`aws_s3_bucket_ownership_controls.files`**: Enforces `BucketOwnerEnforced` settings.
- **CORS Rules**: Enables `PUT`, `GET`, and `HEAD` operations for configured web frontend origins.

### 5. Database Tables (`dynamodb.tf`)
- **`aws_dynamodb_table.file_metadata`**: Pay-per-request table (`FileMetadata`) with `fileId` primary hash key and `ownerId-index` Global Secondary Index (GSI).
- **`aws_dynamodb_table.access_logs`**: Pay-per-request table (`AccessLogs`) with `fileId` hash key, `timestamp` range key, and `ownerId-index` GSI for audit queries.

---

## 📁 Project Structure

```text
securevault-infrastructure/
├── .gitignore               # Infrastructure gitignore rules (excludes state files, plans, zips)
├── apigateway.tf            # REST API Gateway, Cognito authorizer, routes, integrations, & CORS OPTIONS
├── cognito.tf               # Cognito User Pool and web browser app client definitions
├── dynamodb.tf              # DynamoDB tables (FileMetadata & AccessLogs) with GSI indexes
├── iam.tf                   # IAM execution role and least-privilege policies for Lambda
├── lambda.tf                # AWS Lambda function configurations, environment variables, & zip sources
├── main.tf                  # AWS provider initialization and project locals
├── outputs.tf               # Terraform output parameters (API URL, User Pool ID, Bucket Name)
├── README.md                # Infrastructure documentation
├── s3.tf                    # S3 bucket, CORS rules, encryption, and public access blocks
├── variables.tf             # Configurable input variables (AWS Region, project name, origins)
└── versions.tf              # Terraform CLI and AWS provider version requirements
```

---

## ⚙️ Configurable Variables

Defined in `variables.tf`:

| Variable | Description | Default Value |
|---|---|---|
| `aws_region` | AWS region for infrastructure deployment | `ap-south-1` |
| `project_name` | Prefix used for naming provisioned AWS resources | `securevault` |
| `frontend_origin` | Primary frontend web origin for API Gateway CORS responses | `https://main.d3a1aca3sc3925.amplifyapp.com` |
| `allowed_origins` | List of allowed browser origins for S3 & API CORS rules | `["http://localhost:8080", "https://main.d3a1aca3sc3925.amplifyapp.com"]` |

---

## 📤 Terraform Outputs

Defined in `outputs.tf`:

| Output Name | Description |
|---|---|
| `project_name` | Configured project name (`securevault`) |
| `aws_region` | Deployment AWS region (`ap-south-1`) |
| `user_pool_id` | Cognito User Pool ID for user authentication |
| `user_pool_client_id` | Cognito App Client ID for browser integration |
| `api_gateway_url` | Base URL for the deployed API Gateway `dev` stage |
| `s3_files_bucket_name` | Unique name of the provisioned private S3 bucket |
| `s3_files_bucket_arn` | Amazon Resource Name (ARN) of the private S3 bucket |

---

## 🚀 Deployment Instructions

### Prerequisites
- Install [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) (>= 1.0.0).
- Configure AWS authentication credentials using `aws configure` or environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`).
- Build production Lambda deployment packages in `securevault-backend` (`npm run build:lambda`).

### Provisioning Steps

```bash
# 1. Navigate to the infrastructure directory
cd securevault-infrastructure

# 2. Initialize Terraform and download provider plugins
terraform init

# 3. Validate syntax and configuration integrity
terraform validate

# 4. Preview planned infrastructure resources
terraform plan

# 5. Apply configuration and provision AWS resources
terraform apply
```
