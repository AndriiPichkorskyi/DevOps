output "repository_url" {
  description = "URL створеного ECR репозиторію"
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "Full ARN of the repository"
  value       = aws_ecr_repository.this.arn
}
