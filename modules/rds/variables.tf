variable "name" {
  description = "Унікальне ім'я інстансу або кластера (використовується як ідентифікатор ресурсів)"
  type        = string
}

variable "engine" {
  description = "Engine для стандартної RDS-інстанції (наприклад: postgres, mysql)"
  type        = string
  default     = "postgres"
}

variable "engine_cluster" {
  description = "Engine для Aurora-кластера (наприклад: aurora-postgresql, aurora-mysql)"
  type        = string
  default     = "aurora-postgresql"
}

variable "aurora_replica_count" {
  description = "Кількість reader-реплік в Aurora-кластері"
  type        = number
  default     = 1
}

variable "aurora_instance_count" {
  description = "Загальна кількість інстансів Aurora (1 primary + N replicas)"
  type        = number
  default     = 2
}

variable "engine_version" {
  description = "Версія engine для стандартної RDS-інстанції (наприклад: 14.7, 17.2)"
  type        = string
  default     = "14.7"
}

variable "engine_version_cluster" {
  description = "Версія engine для Aurora-кластера (наприклад: 15.3)"
  type        = string
  default     = "15.3"
}

variable "instance_class" {
  description = "Клас інстансу БД (наприклад: db.t3.micro, db.t3.medium, db.r6g.large)"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Розмір диску в гігабайтах (лише для стандартної RDS, ігнорується для Aurora)"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Назва бази даних, яка буде створена при ініціалізації інстансу"
  type        = string
}

variable "username" {
  description = "Ім'я master-користувача бази даних"
  type        = string
}

variable "password" {
  description = "Пароль master-користувача бази даних (sensitive — не відображається в логах)"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "ID VPC, в якому буде розміщена база даних"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR-блок VPC — використовується для обмеження доступу до RDS лише з межами VPC"
  type        = string
}

variable "subnet_private_ids" {
  description = "Список ID приватних підмереж для subnet group (використовується коли publicly_accessible = false)"
  type        = list(string)
}

variable "subnet_public_ids" {
  description = "Список ID публічних підмереж для subnet group (використовується коли publicly_accessible = true)"
  type        = list(string)
}

variable "publicly_accessible" {
  description = "Чи доступна БД з публічного інтернету (true — публічна підмережа, false — приватна)"
  type        = bool
  default     = false
}

variable "multi_az" {
  description = "Увімкнути Multi-AZ deployment для стандартної RDS (підвищена доступність, ігнорується для Aurora)"
  type        = bool
  default     = false
}

variable "parameters" {
  description = "Параметри для parameter group у форматі map (ключ = назва параметру, значення = рядок)"
  type        = map(string)
  default     = {}
}

variable "use_aurora" {
  description = "Тип БД: true — Aurora Cluster (writer + readers), false — стандартна RDS-інстанція"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Кількість днів зберігання автоматичних бекапів (0 — вимкнено, максимум 35)"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Теги, які будуть застосовані до всіх ресурсів модуля"
  type        = map(string)
  default     = {}
}

variable "parameter_group_family_aurora" {
  description = "Family для Aurora parameter group (наприклад: aurora-postgresql15, aurora-mysql8.0)"
  type        = string
  default     = "aurora-postgresql15"
}

variable "parameter_group_family_rds" {
  description = "Family для стандартної RDS parameter group (наприклад: postgres15, mysql8.0)"
  type        = string
  default     = "postgres15"
}

variable "skip_final_snapshot" {
  description = "Пропустити створення фінального snapshot при видаленні (true для dev, false для production)"
  type        = bool
  default     = false
}
