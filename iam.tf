resource "aws_iam_role" "securevault_lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "securevault_lambda_basic_execution" {
  role       = aws_iam_role.securevault_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "securevault_lambda_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.securevault_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query"
        ]
        Resource = [
          aws_dynamodb_table.file_metadata.arn,
          "${aws_dynamodb_table.file_metadata.arn}/index/ownerId-index",
          aws_dynamodb_table.access_logs.arn,
          "${aws_dynamodb_table.access_logs.arn}/index/ownerId-index"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.files.arn}/*"
      }
    ]
  })
}
