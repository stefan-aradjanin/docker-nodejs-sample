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

resource "helm_release" "postgresql" {
  name             = "vega-course-postgresql"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "postgresql"
  version          = "15.5.0"
  namespace        = "vegait-training"
  create_namespace = true

  set {
    name  = "primary.persistence.volumeName"
    value = "vega-course-pv"
  }

  set {
    name  = "primary.persistence.storageClass"
    value = kubernetes_storage_class.ebs_sc.metadata[0].name
  }

  set {
    name  = "primary.persistence.size"
    value = "8Gi"
  }

  set {
    name  = "auth.database"
    value = jsondecode(data.aws_secretsmanager_secret_version.postgres_latest_ver.secret_string)["db"]
  }


  set {
    name  = "auth.username"
    value = jsondecode(data.aws_secretsmanager_secret_version.postgres_latest_ver.secret_string)["username"]
  }

  set {
    name  = "auth.password"
    value = jsondecode(data.aws_secretsmanager_secret_version.postgres_latest_ver.secret_string)["password"]
  }

  set {
    name  = "containerPorts.postgresql"
    value = jsondecode(data.aws_secretsmanager_secret_version.postgres_latest_ver.secret_string)["port"]
  }

  set {
    name  = "serviceAccount.create"
    value = false
  }

  set {
    name  = "primary.persistence.enabled"
    value = true
  }
}
