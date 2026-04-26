provider "aws" {
  region = var.region
}


# Підключаємо модуль для S3 та DynamoDB
module "s3_backend" {
  source      = "./modules/s3-backend"                              # Шлях до модуля
  bucket_name = "andriip-lesson5-tf-state-bucket-1775637482-053639" # Ім'я S3-бакета
  table_name  = "terraform-locks"                                   # Ім'я DynamoDB
}

# Підключаємо модуль для VPC
module "vpc" {
  source             = "./modules/vpc"                                        # Шлях до модуля VPC
  vpc_cidr_block     = "10.0.0.0/16"                                          # CIDR блок для VPC
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]          # Публічні підмережі
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]          # Приватні підмережі
  availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"] # Зони доступності
  vpc_name           = "vpc"                                                  # Ім'я VPC
}

# Підключаємо модуль ECR
module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-5-ecr"
  scan_on_push = true
}

module "eks" {
  source        = "./modules/eks"
  cluster_name  = "eks-cluster-demo-v2"      # Назва кластера
  subnet_ids    = module.vpc.private_subnets # ID підмереж
  instance_type = "t3.small"                 # Тип інстансів
  desired_size  = 3                          # Бажана кількість нодів
  max_size      = 6                          # Максимальна кількість нодів
  min_size      = 3                          # Мінімальна кількість нодів
}

data "aws_eks_cluster" "eks" {
  name       = module.eks.eks_cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks" {
  name       = module.eks.eks_cluster_name
  depends_on = [module.eks]
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}


provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

module "jenkins" {
  source            = "./modules/jenkins"
  cluster_name      = module.eks.eks_cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url

  github_token     = var.github_token
  jenkins_password = var.jenkins_password

  providers = {
    helm       = helm
    kubernetes = kubernetes
    aws        = aws
  }
}


module "argo_cd" {
  source        = "./modules/argo_cd"
  namespace     = "argocd"
  chart_version = "5.46.4"
}

# Підключаємо модуль RDS
module "rds" {
  source = "./modules/rds"

  name       = "myapp-db"
  use_aurora = false # Aurora не доступна на Free Tier

  # --- Aurora-only ---
  engine_cluster                = "aurora-postgresql"
  engine_version_cluster        = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"

  # --- RDS-only ---
  engine                     = "postgres"
  engine_version             = "17.2"
  parameter_group_family_rds = "postgres17"

  # Common
  instance_class          = "db.t3.micro" # Free Tier eligible
  allocated_storage       = 20
  db_name                 = "myapp"
  username                = "postgres"
  password                = var.rds_password
  subnet_private_ids      = module.vpc.private_subnets
  subnet_public_ids       = module.vpc.public_subnets
  publicly_accessible     = true
  vpc_id                  = module.vpc.vpc_id
  vpc_cidr_block          = module.vpc.vpc_cidr_block # CIDR VPC для Security Group
  multi_az                = false                     # Multi-AZ не доступний на Free Tier
  backup_retention_period = 1
  skip_final_snapshot     = true # dev середовище — snapshot не потрібен
  parameters = {
    max_connections            = "200"
    log_min_duration_statement = "500"
  }

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }

  depends_on = [module.vpc] # Чекати поки VPC + IGW + Routes будуть готові
}

module "monitoring" {
  source = "./modules/monitoring"

  grafana_password = var.grafana_password

  providers = {
    helm = helm
  }

  depends_on = [module.eks]
}
