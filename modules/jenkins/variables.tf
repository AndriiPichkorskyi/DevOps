variable "cluster_name" {
  description = "Назва Kubernetes кластера"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC Provider ARN for IRSA"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC Provider URL for IRSA"
  type        = string
}
