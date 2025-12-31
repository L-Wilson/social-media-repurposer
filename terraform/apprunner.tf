# Data source to get the latest image digest from ECR
# This forces Terraform to detect changes when you push a new :latest image
data "aws_ecr_image" "latest" {
  repository_name = aws_ecr_repository.main.name
  image_tag       = "latest"
}

resource "aws_apprunner_service" "main" {
  service_name = var.service_name

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_ecr_access.arn
    }

    image_repository {
      image_configuration {
        port = var.app_port

        runtime_environment_variables = {
          OPENAI_API_KEY = data.aws_secretsmanager_secret_version.openai_api_key.secret_string
          ENVIRONMENT    = var.environment
        }
      }

      image_identifier      = "${aws_ecr_repository.main.repository_url}@${data.aws_ecr_image.latest.image_digest}"
      image_repository_type = "ECR"
    }

    auto_deployments_enabled = false
  }

  instance_configuration {
    cpu               = var.cpu
    memory            = var.memory
    instance_role_arn = aws_iam_role.apprunner_instance.arn
  }

  health_check_configuration {
    protocol            = "HTTP"
    path                = "/health"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 1
    unhealthy_threshold = 5
  }

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.main.arn

  tags = merge(
    local.common_tags,
    {
      name = "${var.service_name}-apprunner-service"
    }
  )
}

resource "aws_apprunner_auto_scaling_configuration_version" "main" {
  auto_scaling_configuration_name = "sm-repurposer-autoscaling"

  max_concurrency = var.max_concurrency
  max_size        = var.max_size
  min_size        = var.min_size

  tags = merge(
    local.common_tags,
    {
      name = "${var.service_name}-autoscaling-config"
    }
  )
}

resource "aws_apprunner_custom_domain_association" "main" {
  count = var.domain_name != "" ? 1 : 0

  service_arn          = aws_apprunner_service.main.arn
  domain_name          = var.domain_name
  enable_www_subdomain = true
}
