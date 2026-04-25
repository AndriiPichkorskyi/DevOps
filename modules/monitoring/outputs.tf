output "prometheus_release_name" {
  description = "Назва Helm release для Prometheus"
  value       = helm_release.prometheus.name
}

output "grafana_namespace" {
  description = "Namespace, де встановлена Grafana"
  value       = helm_release.prometheus.namespace
}

output "grafana_access_command" {
  description = "Команда для локального підключення до Grafana"
  value       = "kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring"
}
