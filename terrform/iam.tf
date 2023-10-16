module "iam_policy_apprunner_access" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "apprunner-access-policy-${var.environment}"
  path        = "/"
  description = "Access to ECR to Apprunner"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:DescribeImages",
        "ecr:GetAuthorizationToken"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

module "apprunner_access_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"

  # https://aws.amazon.com/blogs/security/announcing-an-update-to-iam-role-trust-policy-behavior/
  allow_self_assume_role = true

  trusted_role_services = [
    "build.apprunner.amazonaws.com"
  ]

  custom_role_policy_arns = [
    module.iam_policy_apprunner_access.arn
  ]

  create_role             = true
  create_instance_profile = false

  role_name         = "apprunner-access-role-${var.environment}"
  role_requires_mfa = false

  attach_admin_policy = false

}