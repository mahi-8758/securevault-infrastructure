resource "aws_dynamodb_table" "file_metadata" {
  name         = "FileMetadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "fileId"

  attribute {
    name = "fileId"
    type = "S"
  }

  attribute {
    name = "ownerId"
    type = "S"
  }

  attribute {
    name = "uploadedAt"
    type = "S"
  }

  global_secondary_index {
    name            = "ownerId-index"
    hash_key        = "ownerId"
    range_key       = "uploadedAt"
    projection_type = "ALL"
  }
}

resource "aws_dynamodb_table" "access_logs" {
  name         = "AccessLogs"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "fileId"
  range_key    = "timestamp"

  attribute {
    name = "fileId"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  attribute {
    name = "ownerId"
    type = "S"
  }

  global_secondary_index {
    name            = "ownerId-index"
    hash_key        = "ownerId"
    range_key       = "timestamp"
    projection_type = "ALL"
  }
}