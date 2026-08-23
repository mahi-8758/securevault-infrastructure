# The Cognito user pool stores and authenticates SecureVault users.
resource "aws_cognito_user_pool" "users" {
  name                     = "${var.project_name}-users"
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }
}

# The app client lets the SecureVault browser frontend use the user pool.
resource "aws_cognito_user_pool_client" "web" {
  name         = "${var.project_name}-webclient"
  user_pool_id = aws_cognito_user_pool.users.id

  # Browser applications must not contain a client secret.
  generate_secret = false

  # SRP is the recommended sign-in flow; the password flow supports direct
  # username/password authentication, and refresh tokens keep sessions active.
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
  ]
}