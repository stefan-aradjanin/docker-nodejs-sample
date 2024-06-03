module "secrets_manager" {
  source = "terraform-aws-modules/secrets-manager/aws"

  version     = "1.1.2"
  name        = "vega-course-terraform-postgres"
  description = "PostgreSQL credentials"
  secret_string = jsonencode({
    db       = "",
    username = "",
    password = "",
    port     = 0
  })

  ignore_secret_changes = true
}

data "aws_secretsmanager_secret_version" "postgres_latest_ver" {
  secret_id = module.secrets_manager.secret_id
}
