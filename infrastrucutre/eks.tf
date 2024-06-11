module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "vega-course-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]


  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    vega-node-groups = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"
      ami_type       = "BOTTLEROCKET_x86_64"
      # use_latest_ami_release_version = true

      create_iam_role = true
      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    # One access entry with a policy associated
    vega-course = {
      kubernetes_groups = []
      principal_arn     = module.iam_iam-assumable-role-with-oidc.iam_role_arn

      policy_associations = {
        vega-course = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"
          access_scope = {
            namespaces = ["vegait-training"]
            type       = "namespace"
          }
        }
      }
    }
  }

  cluster_addons = {
    aws-ebs-csi-driver = {
      addon_name                  = "aws-ebs-csi-driver"
      addon_version               = "v1.30.0-eksbuild.1"
      resolve_conflicts_on_update = "PRESERVE"
      service_account_role_arn    = module.iam_irsa-ebs-csi-driver.iam_role_arn
    }
  }
}

resource "kubernetes_storage_class" "ebs_sc" {
  metadata {
    name = "vega-course-ebs-sc"
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  parameters = {
    encrypted = "true"
  }

  depends_on = [module.eks]
}
