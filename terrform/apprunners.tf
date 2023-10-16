module "app_runner_label_studio" {
  source  = "terraform-aws-modules/app-runner/aws"
  version = "1.2.0"

  service_name = "label_studio_${var.environment}"

  # IAM instance profile permissions to access secrets
  instance_policy_statements = {
    GetSecretValue = {
      actions = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      resources = [
        module.s3_assets.s3_bucket_arn,
        "${module.s3_assets.s3_bucket_arn}/*"
      ]
    }
  }
  create_instance_iam_role = true
  instance_iam_role_name   = "apprunner-label-studio-role-${var.environment}"

  # role used to authenticate apprunner in ECR, (can be reused by all our apprunners)
  create_access_iam_role = false

  source_configuration = {
    auto_deployments_enabled = false
    authentication_configuration = {
      access_role_arn = module.apprunner_access_role.iam_role_arn
    }
    image_repository = {
      image_configuration = {
        port = 8080
        runtime_environment_variables = {
          SOME_VARIABLE = "some_value"
        }
        #runtime_environment_secrets = {
        #  SOME_SECRET = aws_secretsmanager_secret.this.arn
        #}
      }
      image_identifier      = module.ecr["label_studio"].repository_url #"public.ecr.aws/aws-containers/hello-app-runner:latest"
      image_repository_type = "ECR"
    }
  }

  # # Requires manual intervention to validate records
  # # https://github.com/hashicorp/terraform-provider-aws/issues/23460
  # create_custom_domain_association = true
  # hosted_zone_id                   = "<TODO>"
  # domain_name                      = "<TODO>"
  # enable_www_subdomain             = true

  create_vpc_connector          = true
  vpc_connector_subnets         = module.vpc.private_subnets
  vpc_connector_security_groups = [module.security_group_apprunner_connector.security_group_id]
  network_configuration = {
    egress_configuration = {
      egress_type = "DEFAULT"
    }
  }
  enable_observability_configuration = false
}



module "security_group_apprunner_connector" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "apprunner-connector"
  description = "Security group for AppRunner connector"
  vpc_id      = module.vpc.vpc_id

  egress_rules       = ["http-80-tcp"]
  egress_cidr_blocks = module.vpc.public_subnets_cidr_blocks
}

module "security_group_apprunner_endpoint" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "apprunner-vpc-endpoints"
  description = "Security group for Apprunner VPC Endpoints"
  vpc_id      = module.vpc.vpc_id

  egress_rules       = ["https-443-tcp"]
  egress_cidr_blocks = [module.vpc.vpc_cidr_block]
}
