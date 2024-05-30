resource "helm_release" "alb-controller" {
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  namespace        = "load-balancer"
  create_namespace = true

  set {
    name  = "region"
    value = var.vpc_region
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  set {
    name  = "serviceAccount.name"
    value = "alb-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_irsa-alb-controller.iam_role_arn
  }

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "cluster.dnsDomain"
    value = var.domain_name
  }

  set {
    name  = "defaultTargetType"
    value = "ip"
  }
}
