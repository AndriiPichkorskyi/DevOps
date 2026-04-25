variable "region" {
  description = "Регіон для розгортання інфраструктури"
  type        = string
  default     = "eu-north-1"
}

variable "github_token" {
  description = "GitHub PAT для Jenkins"
  type        = string
  sensitive   = true
}

variable "jenkins_password" {
  description = "Пароль адміністратора Jenkins"
  type        = string
  sensitive   = true
}
