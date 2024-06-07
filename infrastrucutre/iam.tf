
module "iam_github_oidc_provider" {
  source = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"
}

module "github_actions_ecr_policy" {
  source = "terraform-aws-modules/iam/aws//modules/iam-policy"

  name        = "VegaCourseTerraformGitHubActionPolicy"
  path        = "/"
  description = "Policy for GitHub Actions to interact with ECR"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages",
          "ecr:DeleteRepository",
          "ecr:BatchDeleteImage",
          "ecr:SetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy",
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRoleWithWebIdentity",
          "eks:DescribeNodegroup",
          "eks:ListNodegroups",
          "eks:AccessKubernetesApi",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListIdentityProviderConfigs"
        ],
        Resource = "*"
      }
    ]
  })
}

module "iam_iam-assumable-role-with-oidc" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  create_role = true

  role_name        = "VegaCourseTerraformGitHubActionRole"
  role_description = "GitHub Action Interaction Role"

  role_policy_arns           = [module.github_actions_ecr_policy.arn]
  number_of_role_policy_arns = 1

  provider_url = module.iam_github_oidc_provider.url

  #security-token-service
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
  oidc_subjects_with_wildcards   = ["repo:stefan-aradjanin/docker-nodejs-sample:*"]
}


module "iam_irsa-alb-controller" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "vega-course-alb-irsa"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["load-balancer:alb-controller"]
    }
  }
}

module "iam_irsa-ebs-csi-driver" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "vega-course-ebs-csi-irsa"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}
