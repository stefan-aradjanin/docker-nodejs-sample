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

resource "helm_release" "vega-course-app" {
  name             = "vega-course-app"
  namespace        = "vegait-training"
  create_namespace = false

  repository = "oci://${module.ecr.repository_registry_id}.dkr.ecr.${var.vpc_region}.amazonaws.com"
  chart      = "vega-course-repository"
  version    = "0.1.0"

  set {
    name  = "replicaCount"
    value = 1
  }

  set {
    name  = "name"
    value = "vega-course-app"
  }

  set {
    name  = "namespace"
    value = "vegait-training"
  }

  set {
    name  = "postgres_config.port"
    value = jsondecode(data.aws_secretsmanager_secret_version.postgres_latest_ver.secret_string)["port"]
  }

  set {
    name  = "postgres_config.host"
    value = "vega-course-postgresql"
  }

  set {
    name  = "secrets_config.db"
    value = jsondecode(data.aws_secretsmanager_secret_version.postgres_latest_ver.secret_string)["db"]
  }

  set {
    name  = "secrets_config.user"
    value = jsondecode(data.aws_secretsmanager_secret_version.postgres_latest_ver.secret_string)["username"]
  }

  set {
    name  = "secrets_config.password"
    value = jsondecode(data.aws_secretsmanager_secret_version.postgres_latest_ver.secret_string)["password"]
  }

  set {
    name  = "service.type"
    value = "ClusterIP"
  }

  set {
    name  = "service.port"
    value = 443
  }

  set {
    name  = "service.protocol"
    value = "TCP"
  }

  set {
    name  = "service.name"
    value = "http-service"
  }

  set {
    name  = "ingress.class"
    value = "alb"
  }


  set {
    name  = "ingress.scheme"
    value = "internet-facing"
  }


  set {
    name  = "ingress.type"
    value = "ip"
  }


  set {
    name  = "ingress.ssl_redirect"
    value = 443
  }


  set {
    name  = "ingress.backend_protocol"
    value = "HTTP"
  }


  set {
    name  = "ingress.host"
    value = var.domain_name
  }

  set {
    name  = "ingress.path"
    value = "/"
  }

  set {
    name  = "ingress.pathType"
    value = "Prefix"
  }

  set {
    name  = "image.repository"
    value = "ghcr.io/stefan-aradjanin/stefan-aradjanin/docker-nodejs-sample"
  }

  set {
    name  = "image.tag"
    value = "v1.0.6"
  }

  set {
    name  = "image.pullPolicy"
    value = "IfNotPresent"
  }

  set {
    name  = "image.port"
    value = 3000
  }
}
