module "ecr" {
  source          = "terraform-aws-modules/ecr/aws"
  version         = "1.6.0"
  for_each        = toset([for k, v in local.config.ecr_repositories : v])
  repository_name = each.value

  repository_read_write_access_arns = [module.apprunner_access_role.iam_role_arn]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 10 images",
        selection = {
          tagStatus = "tagged",
          #tagPrefixList = ["v"],
          countType   = "imageCountMoreThan",
          countNumber = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}