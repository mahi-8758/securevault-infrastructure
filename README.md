# ☁️ SecureVault Infrastructure

<p align="center">
  <strong>Terraform Infrastructure as Code for the SecureVault AWS Platform</strong>
</p>

<p align="center">
  <a href="https://youtu.be/W42Mjil9OKo">🎥 Project Demo</a> 
</p>

---

## 📌 Overview

**SecureVault Infrastructure** contains the complete **Terraform Infrastructure as Code (IaC)** configuration used to provision and manage the AWS resources required by the SecureVault platform.

The infrastructure defines a secure, serverless cloud architecture consisting of:

- Amazon Cognito for authentication
- Amazon API Gateway for REST API routing
- AWS Lambda for serverless backend execution
- Amazon S3 for private document storage
- Amazon DynamoDB for file metadata and audit logs
- IAM roles and policies for controlled AWS access
- Amazon CloudWatch logging through Lambda execution roles
- Terraform for repeatable infrastructure provisioning

The infrastructure is maintained separately from the frontend and backend application code.

---

# 🎥 Project Demo

<p align="center">
  <a href="https://youtu.be/W42Mjil9OKo">
    <strong>▶️ Watch the SecureVault Demo</strong>
  </a>
</p>

The demo demonstrates the complete SecureVault application and its AWS-backed serverless architecture.

---

# 🏗️ AWS Architecture

```text
                         ┌──────────────────────┐
                         │       User           │
                         └──────────┬───────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │ Vercel Frontend      │
                         │ HTML / CSS / JS      │
                         └──────────┬───────────┘
                                    │
                           Cognito Authentication
                                    │
                       ┌────────────┴────────────┐
                       │                         │
                       ▼                         ▼
              ┌────────────────┐       ┌────────────────────┐
              │ Amazon Cognito │       │ Amazon API Gateway │
              │  User Pool     │       │     REST API       │
              └────────────────┘       └─────────┬──────────┘
                                                 │
                                                 ▼
                                        ┌─────────────────┐
                                        │   AWS Lambda    │
                                        │ Serverless APIs │
                                        └────────┬────────┘
                                                 │
                              ┌──────────────────┼──────────────────┐
                              │                  │                  │
                              ▼                  ▼                  ▼
                       ┌─────────────┐   ┌──────────────┐   ┌─────────────┐
                       │ Amazon S3   │   │ FileMetadata │   │ AccessLogs  │
                       │ Private     │   │  DynamoDB    │   │  DynamoDB   │
                       │ File Store  │   │    Table     │   │    Table    │
                       └─────────────┘   └──────────────┘   └─────────────┘
```

---

# ✨ Infrastructure Highlights

### 🔐 Authentication

Terraform provisions:

- Cognito User Pool
- Cognito web application client
- Email-based authentication and verification
- Password policy configuration
- Browser authentication configuration

### 🌐 API Gateway

The infrastructure provisions a regional REST API with Cognito authorization.

Configured routes include:

```text
POST   /upload
GET    /files
GET    /files/{fileId}
DELETE /files/{fileId}
GET    /download/{fileId}
GET    /audit
```

CORS preflight `OPTIONS` integrations are also configured for browser-based frontend access.

### ⚡ Serverless Compute

Five Node.js 20.x Lambda functions are provisioned:

```text
securevault-upload
securevault-files
securevault-download
securevault-delete
securevault-audit
```

Each function handles a specific part of the SecureVault backend workflow.

### 🪣 Secure S3 Storage

The infrastructure provisions a private S3 bucket with:

- Public access blocking
- Server-side AES256 encryption
- Object versioning
- Bucket-owner-enforced ownership controls
- Configured CORS rules
- Private document storage

### 🗄️ DynamoDB

Two pay-per-request DynamoDB tables are provisioned:

#### `FileMetadata`

```text
Primary Key:
  fileId

Global Secondary Index:
  ownerId-index
```

Used to store document metadata and query files belonging to a user.

#### `AccessLogs`

```text
Partition Key:
  fileId

Sort Key:
  timestamp

Global Secondary Index:
  ownerId-index
```

Used to store and retrieve file access activity.

### 🔑 IAM

Terraform provisions a Lambda execution role with permissions required for:

- CloudWatch logging
- S3 operations
- DynamoDB operations

The role is used by the Lambda functions to access AWS resources without embedding credentials in application code.

---

# ☁️ AWS Services

| AWS Service | Infrastructure Purpose |
|---|---|
| **Amazon Cognito** | User Pool and browser authentication client |
| **Amazon API Gateway** | REST API, routes, integrations, and Cognito authorizer |
| **AWS Lambda** | Serverless backend functions |
| **Amazon S3** | Private document storage |
| **Amazon DynamoDB** | Metadata and audit log persistence |
| **IAM** | Lambda execution roles and permissions |
| **Amazon CloudWatch** | Lambda execution logging and monitoring |
| **Terraform** | Infrastructure as Code |

---

# 📦 Provisioned Resources

## 1. Amazon Cognito — `cognito.tf`

Terraform provisions:

### `aws_cognito_user_pool.users`

Provides:

- User identity management
- Email-based authentication
- Email verification
- Password policy enforcement

### `aws_cognito_user_pool_client.web`

Provides a browser application client configured for the SecureVault frontend.

---

## 2. API Gateway — `apigateway.tf`

### REST API

```text
aws_api_gateway_rest_api.securevault
```

Provides the SecureVault REST API.

### Cognito Authorizer

```text
aws_api_gateway_authorizer.securevault
```

Protects API routes using Cognito User Pool authentication.

### API Routes

```text
/upload
/files
/files/{fileId}
/download/{fileId}
/audit
```

The infrastructure also configures Lambda integrations, CORS preflight responses, and the `dev` deployment stage.

---

## 3. Lambda & IAM — `lambda.tf` / `iam.tf`

Lambda functions:

```text
securevault-upload
securevault-files
securevault-download
securevault-delete
securevault-audit
```

Runtime:

```text
Node.js 20.x
```

The Lambda execution role provides controlled access to required AWS resources and CloudWatch logging.

---

## 4. Amazon S3 — `s3.tf`

The infrastructure creates a private document storage bucket.

Security configuration includes:

```text
Public Access Block
        +
AES256 Server-Side Encryption
        +
Object Versioning
        +
BucketOwnerEnforced Ownership
        +
CORS Configuration
```

Files are transferred using presigned URLs generated by the backend Lambda functions.

---

## 5. DynamoDB — `dynamodb.tf`

### FileMetadata

Stores information about uploaded files.

```text
Table: FileMetadata
Primary Key: fileId
GSI: ownerId-index
Billing: PAY_PER_REQUEST
```

### AccessLogs

Stores file activity history.

```text
Table: AccessLogs
Partition Key: fileId
Sort Key: timestamp
GSI: ownerId-index
Billing: PAY_PER_REQUEST
```

---

# 🔄 Infrastructure & Application Flow

```text
1. User authenticates
        │
        ▼
2. Amazon Cognito
        │
        ▼
3. Cognito JWT
        │
        ▼
4. API Gateway
        │
        ▼
5. Cognito Authorizer
        │
        ▼
6. AWS Lambda
        │
        ├──────────► Amazon S3
        │             File Storage
        │
        └──────────► DynamoDB
                      Metadata + Audit Logs
```

---

# 🔐 Security Architecture

SecureVault infrastructure is designed around controlled access and private storage.

### Cognito Authentication

API Gateway routes are protected using a Cognito User Pool authorizer.

### IAM Access Control

Lambda functions use an IAM execution role rather than application-level AWS access keys.

### Private S3 Bucket

Public access is blocked on the document storage bucket.

### Server-Side Encryption

S3 objects use default AES256 server-side encryption.

### Presigned URLs

The backend generates temporary S3 URLs for file upload and download operations.

### Ownership Validation

Application-level Lambda logic validates the authenticated Cognito identity before performing file operations.

### Versioning

S3 object versioning is enabled for additional data protection.

---

# 📁 Repository Structure

```text
securevault-infrastructure/
│
├── .gitignore
├── apigateway.tf
├── cognito.tf
├── dynamodb.tf
├── iam.tf
├── lambda.tf
├── main.tf
├── outputs.tf
├── README.md
├── s3.tf
├── variables.tf
└── versions.tf
```

### Terraform Files

| File | Purpose |
|---|---|
| `main.tf` | AWS provider configuration and project locals |
| `versions.tf` | Terraform and AWS provider requirements |
| `variables.tf` | Configurable infrastructure variables |
| `cognito.tf` | Cognito User Pool and web client |
| `apigateway.tf` | REST API, routes, integrations, authorizer, and CORS |
| `lambda.tf` | Lambda function configurations |
| `iam.tf` | IAM roles and policies |
| `s3.tf` | S3 bucket, encryption, versioning, ownership, and CORS |
| `dynamodb.tf` | FileMetadata and AccessLogs tables |
| `outputs.tf` | Useful deployment outputs |

---

# ⚙️ Configurable Variables

The primary infrastructure variables are defined in `variables.tf`.

| Variable | Description | Default |
|---|---|---|
| `aws_region` | AWS deployment region | `ap-south-1` |
| `project_name` | Resource naming prefix | `securevault` |
| `frontend_origin` | Primary frontend origin | Project-configured value |
| `allowed_origins` | Allowed browser origins for CORS | Local + deployed frontend origins |

The current deployed frontend is hosted at:

```text
https://securevault-frontend-one.vercel.app/
```

Local development uses:

```text
http://localhost:8080
```

---

# 📤 Terraform Outputs

After deployment, Terraform exposes useful outputs including:

| Output | Description |
|---|---|
| `project_name` | SecureVault project name |
| `aws_region` | AWS deployment region |
| `user_pool_id` | Cognito User Pool ID |
| `user_pool_client_id` | Cognito browser client ID |
| `api_gateway_url` | API Gateway `dev` stage URL |
| `s3_files_bucket_name` | Private S3 bucket name |
| `s3_files_bucket_arn` | S3 bucket ARN |

View outputs with:

```bash
terraform output
```

---

# 🚀 Deployment

## Prerequisites

Install and configure:

- Terraform CLI
- AWS CLI
- Node.js
- npm
- An AWS account with permissions to provision the required resources

Verify Terraform:

```bash
terraform version
```

Verify AWS CLI:

```bash
aws --version
```

Configure AWS authentication:

```bash
aws configure
```

---

## 1. Build Backend Lambda Packages

Before deploying the infrastructure, build the Lambda deployment packages from the backend repository:

```bash
npm run build:lambda
```

The generated Lambda ZIP packages are consumed by this infrastructure repository.

---

## 2. Navigate to Infrastructure

```bash
cd securevault-infrastructure
```

---

## 3. Initialize Terraform

```bash
terraform init
```

---

## 4. Format Terraform

```bash
terraform fmt
```

---

## 5. Validate Configuration

```bash
terraform validate
```

---

## 6. Review the Deployment Plan

```bash
terraform plan
```

Always review the planned changes before applying infrastructure.

---

## 7. Deploy

```bash
terraform apply
```

Confirm the deployment when Terraform prompts for approval.

---

## 8. View Outputs

```bash
terraform output
```

---

# 🔁 Updating the Infrastructure

When infrastructure changes are made:

```bash
terraform fmt
terraform validate
terraform plan
terraform apply
```

For Lambda code changes, rebuild the backend deployment packages before running Terraform:

```bash
npm run build:lambda
```

---

# 🧹 Destroying Resources

**Warning:** This permanently removes infrastructure and may delete project data depending on the resource configuration.

To destroy the Terraform-managed resources:

```bash
terraform destroy
```

Review the plan carefully before confirming.

---

# 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| **Terraform / HCL** | Infrastructure as Code |
| **AWS Provider** | Terraform AWS resource management |
| **Amazon Cognito** | Authentication |
| **API Gateway** | REST API |
| **AWS Lambda** | Serverless compute |
| **Amazon S3** | Cloud file storage |
| **Amazon DynamoDB** | NoSQL database |
| **IAM** | Access control |
| **CloudWatch** | Logging and monitoring |

---

# 🎯 Project Objectives

This infrastructure repository demonstrates practical experience with:

- Infrastructure as Code
- Terraform resource management
- Serverless AWS architecture
- API Gateway configuration
- Cognito authorization
- Lambda deployment
- S3 security
- DynamoDB schema design
- IAM permissions
- CORS configuration
- Repeatable cloud deployments
- Separation of application and infrastructure code

---

# 📚 What I Learned

Through the infrastructure component of SecureVault, I gained practical experience in:

- Designing AWS serverless infrastructure
- Writing Terraform HCL configurations
- Managing AWS resources declaratively
- Connecting API Gateway with Lambda
- Configuring Cognito authorizers
- Creating DynamoDB tables and GSIs
- Securing S3 buckets
- Designing IAM execution roles
- Managing CORS across cloud services
- Packaging Lambda functions for Terraform deployment
- Using Terraform plan/apply workflows
- Debugging infrastructure deployment issues

---

# 🧩 Related Repositories

### 🎨 Frontend

https://github.com/mahi-8758/securevault-frontend

### ⚙️ Backend

https://github.com/mahi-8758/securevault-backend

### 🏗️ Infrastructure

https://github.com/mahi-8758/securevault-infrastructure

---

# 🎥 Demo

**YouTube Demo:**  
https://youtu.be/W42Mjil9OKo

---

# 👨‍💻 Author

**Mahi Kumar**

SecureVault is an AWS cloud project demonstrating secure serverless architecture, Infrastructure as Code, cloud storage, authentication, database integration, and backend API deployment.

---

<p align="center">
  <strong>☁️ SecureVault — Infrastructure as Code. Serverless AWS. Secure Cloud.</strong>
</p>
