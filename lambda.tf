resource "aws_lambda_function" "upload" {
  function_name    = "securevault-upload"
  filename         = "${path.module}/lambda-packages/upload.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda-packages/upload.zip")
  role             = aws_iam_role.securevault_lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  memory_size      = 256
  timeout          = 30

  environment {
    variables = {
      METADATA_TABLE = "FileMetadata"
      AUDIT_TABLE    = "AccessLogs"
      FILES_BUCKET   = aws_s3_bucket.files.bucket
    }
  }
}

resource "aws_lambda_function" "files" {
  function_name    = "securevault-files"
  filename         = "${path.module}/lambda-packages/files.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda-packages/files.zip")
  role             = aws_iam_role.securevault_lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  memory_size      = 256
  timeout          = 30

  environment {
    variables = {
      METADATA_TABLE = "FileMetadata"
      AUDIT_TABLE    = "AccessLogs"
      OWNER_INDEX    = "ownerId-index"
    }
  }
}

resource "aws_lambda_function" "download" {
  function_name    = "securevault-download"
  filename         = "${path.module}/lambda-packages/download.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda-packages/download.zip")
  role             = aws_iam_role.securevault_lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  memory_size      = 256
  timeout          = 30

  environment {
    variables = {
      METADATA_TABLE = "FileMetadata"
      AUDIT_TABLE    = "AccessLogs"
      FILES_BUCKET   = aws_s3_bucket.files.bucket
    }
  }
}

resource "aws_lambda_function" "delete" {
  function_name    = "securevault-delete"
  filename         = "${path.module}/lambda-packages/delete.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda-packages/delete.zip")
  role             = aws_iam_role.securevault_lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  memory_size      = 256
  timeout          = 30

  environment {
    variables = {
      METADATA_TABLE = "FileMetadata"
      AUDIT_TABLE    = "AccessLogs"
      FILES_BUCKET   = aws_s3_bucket.files.bucket
    }
  }
}

resource "aws_lambda_function" "audit" {
  function_name    = "securevault-audit"
  filename         = "${path.module}/lambda-packages/audit.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda-packages/audit.zip")
  role             = aws_iam_role.securevault_lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  memory_size      = 256
  timeout          = 30

  environment {
    variables = {
      AUDIT_TABLE       = "AccessLogs"
      AUDIT_OWNER_INDEX = "ownerId-index"
    }
  }
}