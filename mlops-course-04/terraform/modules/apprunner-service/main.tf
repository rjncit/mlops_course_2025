resource "aws_apprunner_service" "ars" {
  service_name = "${local.service_name}-v2"  # <- ensure unique name

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.iamr.arn
    }

    image_repository {
      image_identifier      = var.source_configuration.image_repository.image_identifier
      image_repository_type = var.source_configuration.image_repository.image_repository_type

      image_configuration {
        port = 80  # Ensure this matches your Dockerfile
      }
    }

    auto_deployments_enabled = var.source_configuration.auto_deployments_enabled
  }

  health_check_configuration {
    protocol            = "HTTP"
    path                = "/"               # Change to a real route like "/ping" if needed
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = var.tags
}

resource "aws_iam_role" "iamr" {
  name = "${local.service_name}-ars-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "iamrpa" {
  role       = aws_iam_role.iamr.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}
