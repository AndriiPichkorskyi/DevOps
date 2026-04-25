resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  version          = "56.6.2"

  # Задаємо дефолтний пароль для Grafana (admin / admin)
  set {
    name  = "grafana.adminPassword"
    value = "admin_PASSWORD_HERE"
  }
}
