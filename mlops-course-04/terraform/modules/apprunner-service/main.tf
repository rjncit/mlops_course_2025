resource "aws_apprunner_service" "ars" {
  service_name = local.service_name

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.iamr.arn
    }

    image_repository {
      image_identifier      = var.source_configuration.image_repository.image_identifier
      image_repository_type = var.source_configuration.image_repository.image_repository_type
      image_configuration {
        port = var.source_configuration.image_repository.image_configuration.port
      }
    }

    auto_deployments_enabled = var.source_configuration.auto_deployments_enabled
  }

  # Add health check config here:
  health_check_configuration {
    protocol            = "HTTP"
    path                = "/"           # Adjust if your app has a different health path
    interval            = 10            # seconds between health checks
    timeout             = 5             # seconds to wait for response
    healthy_threshold   = 2             # consecutive successes before healthy
    unhealthy_threshold = 2             # consecutive failures before unhealthy
  }

  tags = var.tags
}

resource "aws_iam_role" "iamr" {
  name = "${local.service_name}-ars-iam-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "build.apprunner.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "iamrpa" {
  role       = aws_iam_role.iamr.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}
