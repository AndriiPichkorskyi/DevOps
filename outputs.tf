#-------------Backend-----------------

output "s3_bucket_name" {
  description = "Назва S3-бакета для стейтів"
  value       = module.s3_backend.s3_bucket_name
}

output "dynamodb_table_name" {
  description = "Назва таблиці DynamoDB для блокування стейтів"
  value       = module.s3_backend.dynamodb_table_name
}
#-------------VPC-----------------

output "vpc_id" {
  description = "ID створеної VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

#-------------ECR-----------------

output "repository_url" {
  description = "URL створеного ECR репозиторію"
  value       = module.ecr.repository_url
}

#-------------EKS-----------------

output "eks_cluster_endpoint" {
  description = "EKS API endpoint for connecting to the cluster"
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.eks_cluster_name
}



output "eks_node_role_arn" {
  description = "IAM role ARN for EKS Worker Nodes"
  value       = module.eks.eks_node_role_arn
}

#-------------jenkins-----------------

output "jenkins_release" {
  value = module.jenkins.jenkins_release_name
}

output "jenkins_namespace" {
  value = module.jenkins.jenkins_namespace
}

#-------------RDS-----------------

output "rds_endpoint" {
  description = "Endpoint бази даних RDS"
  value       = module.rds.endpoint
}

#-------------URLs Helper-----------------

output "get_all_urls_command" {
  description = "Команди для швидкого отримання всіх публічних URL за допомогою kubectl"
  value       = <<EOF

# Щоб миттєво отримати всі URL-адреси до ваших сервісів, виконайте:
echo "Jenkins URL:  http://$(kubectl get svc jenkins -n jenkins -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "ArgoCD URL:   http://$(kubectl get svc argo-cd-argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "Django App:   http://$(kubectl get svc example-app-django -n default -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"

EOF
}
