# IAM role for App Runner to access ECR
resource "aws_iam_role" "apprunner_ecr_access" {
  name = "${var.service_name}-apprunner-ecr-access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "build.apprunner.amazonaws.com"
      }
    }]
  })

  tags = merge(
    local.common_tags,
    {
      name = "${var.service_name}-apprunner-ecr-access-role"
    }
  )
}

# Attach AWS managed policy for ECR access
resource "aws_iam_role_policy_attachment" "apprunner_ecr_access" {
  role       = aws_iam_role.apprunner_ecr_access.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# IAM role for the App Runner instance (application runtime)
resource "aws_iam_role" "apprunner_instance" {
  name = "${var.service_name}-apprunner-instance"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "tasks.apprunner.amazonaws.com"
      }
    }]
  })

  tags = merge(
    local.common_tags,
    {
      name = "${var.service_name}-apprunner-instance-role"
    }
  )
}

# Policy to allow App Runner instance to read secrets from Secrets Manager
resource "aws_iam_role_policy" "apprunner_secrets_access" {
  name = "${var.service_name}-apprunner-secrets-access"
  role = aws_iam_role.apprunner_instance.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = data.aws_secretsmanager_secret.openai_api_key.arn
    }]
  })
}
