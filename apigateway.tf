resource "aws_api_gateway_rest_api" "securevault" {
  name        = "SecureVault API"
  description = "Serverless API for SecureVault"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_authorizer" "securevault" {
  name                             = "securevault-cognito-authorizer"
  rest_api_id                      = aws_api_gateway_rest_api.securevault.id
  type                             = "COGNITO_USER_POOLS"
  identity_source                  = "method.request.header.Authorization"
  provider_arns                    = [aws_cognito_user_pool.users.arn]
  authorizer_result_ttl_in_seconds = 300
}

resource "aws_api_gateway_resource" "upload" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  parent_id   = aws_api_gateway_rest_api.securevault.root_resource_id
  path_part   = "upload"
}

resource "aws_api_gateway_resource" "files" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  parent_id   = aws_api_gateway_rest_api.securevault.root_resource_id
  path_part   = "files"
}

resource "aws_api_gateway_resource" "download" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  parent_id   = aws_api_gateway_rest_api.securevault.root_resource_id
  path_part   = "download"
}

resource "aws_api_gateway_resource" "file_id" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  parent_id   = aws_api_gateway_resource.download.id
  path_part   = "{fileId}"
}

resource "aws_api_gateway_resource" "file_id_delete" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  parent_id   = aws_api_gateway_resource.files.id
  path_part   = "{fileId}"
}

resource "aws_api_gateway_resource" "audit" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  parent_id   = aws_api_gateway_rest_api.securevault.root_resource_id
  path_part   = "audit"
}

resource "aws_api_gateway_method" "upload" {
  rest_api_id      = aws_api_gateway_rest_api.securevault.id
  resource_id      = aws_api_gateway_resource.upload.id
  http_method      = "POST"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.securevault.id
  api_key_required = false
}

resource "aws_api_gateway_method" "files" {
  rest_api_id      = aws_api_gateway_rest_api.securevault.id
  resource_id      = aws_api_gateway_resource.files.id
  http_method      = "GET"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.securevault.id
  api_key_required = false
}

resource "aws_api_gateway_method" "download" {
  rest_api_id      = aws_api_gateway_rest_api.securevault.id
  resource_id      = aws_api_gateway_resource.file_id.id
  http_method      = "GET"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.securevault.id
  api_key_required = false

  request_parameters = {
    "method.request.path.fileId" = true
  }
}

resource "aws_api_gateway_method" "file_get" {
  rest_api_id      = aws_api_gateway_rest_api.securevault.id
  resource_id      = aws_api_gateway_resource.file_id_delete.id
  http_method      = "GET"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.securevault.id
  api_key_required = false

  request_parameters = {
    "method.request.path.fileId" = true
  }
}

resource "aws_api_gateway_method" "delete" {
  rest_api_id      = aws_api_gateway_rest_api.securevault.id
  resource_id      = aws_api_gateway_resource.file_id_delete.id
  http_method      = "DELETE"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.securevault.id
  api_key_required = false

  request_parameters = {
    "method.request.path.fileId" = true
  }
}

resource "aws_api_gateway_method" "audit" {
  rest_api_id      = aws_api_gateway_rest_api.securevault.id
  resource_id      = aws_api_gateway_resource.audit.id
  http_method      = "GET"
  authorization    = "COGNITO_USER_POOLS"
  authorizer_id    = aws_api_gateway_authorizer.securevault.id
  api_key_required = false
}

resource "aws_api_gateway_integration" "upload" {
  rest_api_id             = aws_api_gateway_rest_api.securevault.id
  resource_id             = aws_api_gateway_resource.upload.id
  http_method             = aws_api_gateway_method.upload.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.upload.arn}/invocations"
}

resource "aws_api_gateway_integration" "files" {
  rest_api_id             = aws_api_gateway_rest_api.securevault.id
  resource_id             = aws_api_gateway_resource.files.id
  http_method             = aws_api_gateway_method.files.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.files.arn}/invocations"
}

resource "aws_api_gateway_integration" "download" {
  rest_api_id             = aws_api_gateway_rest_api.securevault.id
  resource_id             = aws_api_gateway_resource.file_id.id
  http_method             = aws_api_gateway_method.download.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.download.arn}/invocations"
}

resource "aws_api_gateway_integration" "file_get" {
  rest_api_id             = aws_api_gateway_rest_api.securevault.id
  resource_id             = aws_api_gateway_resource.file_id_delete.id
  http_method             = aws_api_gateway_method.file_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.files.arn}/invocations"
}

resource "aws_api_gateway_integration" "delete" {
  rest_api_id             = aws_api_gateway_rest_api.securevault.id
  resource_id             = aws_api_gateway_resource.file_id_delete.id
  http_method             = aws_api_gateway_method.delete.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.delete.arn}/invocations"
}

resource "aws_api_gateway_integration" "audit" {
  rest_api_id             = aws_api_gateway_rest_api.securevault.id
  resource_id             = aws_api_gateway_resource.audit.id
  http_method             = aws_api_gateway_method.audit.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.audit.arn}/invocations"
}

resource "aws_lambda_permission" "upload" {
  statement_id  = "AllowExecutionFromAPIGatewayUpload"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.securevault.execution_arn}/*/*"
}

resource "aws_lambda_permission" "files" {
  statement_id  = "AllowExecutionFromAPIGatewayFiles"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.files.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.securevault.execution_arn}/*/*"
}

resource "aws_lambda_permission" "download" {
  statement_id  = "AllowExecutionFromAPIGatewayDownload"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.download.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.securevault.execution_arn}/*/*"
}

resource "aws_lambda_permission" "delete" {
  statement_id  = "AllowExecutionFromAPIGatewayDelete"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.securevault.execution_arn}/*/*"
}

resource "aws_lambda_permission" "audit" {
  statement_id  = "AllowExecutionFromAPIGatewayAudit"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.audit.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.securevault.execution_arn}/*/*"
}

resource "aws_api_gateway_method" "upload_options" {
  rest_api_id      = aws_api_gateway_rest_api.securevault.id
  resource_id      = aws_api_gateway_resource.upload.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_method" "files_options" {
  rest_api_id      = aws_api_gateway_rest_api.securevault.id
  resource_id      = aws_api_gateway_resource.files.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_method" "download_options" {
  rest_api_id      = aws_api_gateway_rest_api.securevault.id
  resource_id      = aws_api_gateway_resource.file_id.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_method" "delete_options" {
  rest_api_id      = aws_api_gateway_rest_api.securevault.id
  resource_id      = aws_api_gateway_resource.file_id_delete.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_method" "audit_options" {
  rest_api_id      = aws_api_gateway_rest_api.securevault.id
  resource_id      = aws_api_gateway_resource.audit.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_integration" "upload_options" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  resource_id = aws_api_gateway_resource.upload.id
  http_method = aws_api_gateway_method.upload_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "files_options" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  resource_id = aws_api_gateway_resource.files.id
  http_method = aws_api_gateway_method.files_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "download_options" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  resource_id = aws_api_gateway_resource.file_id.id
  http_method = aws_api_gateway_method.download_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "delete_options" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  resource_id = aws_api_gateway_resource.file_id_delete.id
  http_method = aws_api_gateway_method.delete_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "audit_options" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  resource_id = aws_api_gateway_resource.audit.id
  http_method = aws_api_gateway_method.audit_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "upload_options_200" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  resource_id = aws_api_gateway_resource.upload.id
  http_method = aws_api_gateway_method.upload_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "files_options_200" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  resource_id = aws_api_gateway_resource.files.id
  http_method = aws_api_gateway_method.files_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "download_options_200" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  resource_id = aws_api_gateway_resource.file_id.id
  http_method = aws_api_gateway_method.download_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "delete_options_200" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  resource_id = aws_api_gateway_resource.file_id_delete.id
  http_method = aws_api_gateway_method.delete_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_method_response" "audit_options_200" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  resource_id = aws_api_gateway_resource.audit.id
  http_method = aws_api_gateway_method.audit_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }
}

resource "aws_api_gateway_integration_response" "upload_options_200" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  resource_id = aws_api_gateway_resource.upload.id
  http_method = aws_api_gateway_method.upload_options.http_method
  status_code = aws_api_gateway_method_response.upload_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,DELETE,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "files_options_200" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  resource_id = aws_api_gateway_resource.files.id
  http_method = aws_api_gateway_method.files_options.http_method
  status_code = aws_api_gateway_method_response.files_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,DELETE,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "download_options_200" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  resource_id = aws_api_gateway_resource.file_id.id
  http_method = aws_api_gateway_method.download_options.http_method
  status_code = aws_api_gateway_method_response.download_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,DELETE,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "delete_options_200" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  resource_id = aws_api_gateway_resource.file_id_delete.id
  http_method = aws_api_gateway_method.delete_options.http_method
  status_code = aws_api_gateway_method_response.delete_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,DELETE,OPTIONS'"
  }
}

resource "aws_api_gateway_integration_response" "audit_options_200" {
  rest_api_id = aws_api_gateway_rest_api.securevault.id
  resource_id = aws_api_gateway_resource.audit.id
  http_method = aws_api_gateway_method.audit_options.http_method
  status_code = aws_api_gateway_method_response.audit_options_200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.frontend_origin}'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,DELETE,OPTIONS'"
  }
}

resource "aws_api_gateway_deployment" "securevault" {
  depends_on = [
    aws_api_gateway_integration.upload,
    aws_api_gateway_integration.files,
    aws_api_gateway_integration.download,
    aws_api_gateway_integration.file_get,
    aws_api_gateway_integration.delete,
    aws_api_gateway_integration.audit,
    aws_api_gateway_integration.upload_options,
    aws_api_gateway_integration.files_options,
    aws_api_gateway_integration.download_options,
    aws_api_gateway_integration.delete_options,
    aws_api_gateway_integration.audit_options,
    aws_api_gateway_method_response.download_options_200,
    aws_api_gateway_integration_response.download_options_200,
    aws_api_gateway_method_response.delete_options_200,
    aws_api_gateway_integration_response.delete_options_200,
  ]

  lifecycle {
    create_before_destroy = true
  }

  rest_api_id = aws_api_gateway_rest_api.securevault.id

  triggers = {
    redeployment = sha1(join(",", [
      aws_api_gateway_rest_api.securevault.id,
      aws_api_gateway_resource.upload.id,
      aws_api_gateway_resource.files.id,
      aws_api_gateway_resource.download.id,
      aws_api_gateway_resource.file_id.id,
      aws_api_gateway_resource.audit.id,
      aws_api_gateway_method.upload.id,
      aws_api_gateway_method.files.id,
      aws_api_gateway_method.download.id,
      aws_api_gateway_method.file_get.id,
      aws_api_gateway_method.delete.id,
      aws_api_gateway_method.audit.id,
      aws_api_gateway_integration.upload.id,
      aws_api_gateway_integration.files.id,
      aws_api_gateway_integration.download.id,
      aws_api_gateway_integration.file_get.id,
      aws_api_gateway_integration.delete.id,
      aws_api_gateway_integration.audit.id,
      aws_api_gateway_method.upload_options.id,
      aws_api_gateway_method.files_options.id,
      aws_api_gateway_method.download_options.id,
      aws_api_gateway_method.delete_options.id,
      aws_api_gateway_method.audit_options.id,
      aws_api_gateway_method_response.download_options_200.id,
      aws_api_gateway_integration_response.download_options_200.id,
      aws_api_gateway_method_response.delete_options_200.id,
      aws_api_gateway_integration_response.delete_options_200.id,
    ]))
  }
}

resource "aws_api_gateway_stage" "dev" {
  deployment_id = aws_api_gateway_deployment.securevault.id
  rest_api_id   = aws_api_gateway_rest_api.securevault.id
  stage_name    = "dev"
}
