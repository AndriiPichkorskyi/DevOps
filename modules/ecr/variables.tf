variable "ecr_name" {
  description = "Назва ECR репозиторію"
  type        = string
}

variable "scan_on_push" {
  description = "Чи сканувати образи на вразливості при пуші"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Теги для ресурсів"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "lesson-5"
  }
}
