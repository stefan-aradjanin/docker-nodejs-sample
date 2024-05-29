module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "vega-course-cluster"
  cluster_version = "1.29"

  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = [var.my_office_cidr]

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    vega-node-groups = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types                 = ["t3.micro"]
      capacity_type                  = "ON_DEMAND"
      ami_type                       = "BOTTLEROCKET_x86_64"
      use_latest_ami_release_version = true

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
            namespaces = ["vega-course-namespace"]
            type       = "namespace"
          }
        }
      }
    }
  }
}
