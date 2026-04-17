# Endpoint для стандартної RDS (use_aurora = false)
output "rds_endpoint" {
  description = "Endpoint стандартної RDS-інстанції"
  value       = var.use_aurora ? null : try(aws_db_instance.standard[0].endpoint, null)
}

# Endpoint Aurora Cluster (use_aurora = true)
output "aurora_endpoint" {
  description = "Writer endpoint Aurora-кластера"
  value       = var.use_aurora ? try(aws_rds_cluster.aurora[0].endpoint, null) : null
}

# Reader endpoint Aurora
output "aurora_reader_endpoint" {
  description = "Reader endpoint Aurora-кластера"
  value       = var.use_aurora ? try(aws_rds_cluster.aurora[0].reader_endpoint, null) : null
}

# Уніфікований вивід — повертає актуальний endpoint незалежно від типу БД
output "endpoint" {
  description = "Активний endpoint бази даних (Aurora writer або стандартна RDS)"
  value       = var.use_aurora ? try(aws_rds_cluster.aurora[0].endpoint, null) : try(aws_db_instance.standard[0].endpoint, null)
}
