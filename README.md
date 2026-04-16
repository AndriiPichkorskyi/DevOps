# CI/CD Infrastructure: Jenkins + Argo CD on AWS EKS

Цей проєкт автоматизує повний CI/CD процес для Django-застосунку з використанням **Jenkins** (CI), **Argo CD** (CD), **Helm** та **Terraform** на кластері **Amazon EKS**.

---

## Скріншоти

### Jenkins — Успішний CI Pipeline

![Jenkins Pipeline](./screenshots/jenkins.webp)

### Argo CD — Синхронізований застосунок

![Argo CD](./screenshots/argocd.webp)

### Django — Задеплоєний застосунок

![Django App](./screenshots/django.webp)

### Граф Інфраструктури

![Terraform Graph](./screenshots/graph.svg)

---

## Схема CI/CD процесу

```
Зміна коду в GitHub
       │
       ▼
  Jenkins Pipeline
  ┌─────────────────────────────────┐
  │ 1. Kaniko: збирає Docker-образ  │
  │ 2. Пушить образ в AWS ECR       │
  │ 3. Оновлює tag у values.yaml    │
  │ 4. Пушить зміни в GitHub        │
  └─────────────────────────────────┘
       │
       ▼
  Git репозиторій (values.yaml оновлено)
       │
       ▼
  Argo CD (автоматично виявляє зміни)
       │
       ▼
  Kubernetes (EKS): деплоїть нову версію
```

---

## Структура проєкту

```
devops/
├── main.tf                  # Підключення всіх модулів
├── backend.tf               # Terraform backend (S3 + DynamoDB)
├── outputs.tf               # Виводи ресурсів
├── Jenkinsfile              # CI pipeline (збірка, пуш, оновлення тегу)
│
├── modules/
│   ├── s3-backend/          # S3 для стейту + DynamoDB для локінгу
│   ├── vpc/                 # VPC, публічні/приватні підмережі, NAT
│   ├── ecr/                 # ECR репозиторій для Docker-образів
│   ├── eks/                 # EKS кластер + node group + EBS CSI driver
│   ├── jenkins/             # Jenkins (Helm) + IRSA для ECR + JCasC
│   └── argo_cd/             # Argo CD (Helm) + Application CRDs
│       └── charts/          # Helm-чарт для створення Argo CD Applications
│
├── charts/
│   └── django-app/          # Helm-чарт Django застосунку
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── configmap.yaml
│       │   ├── hpa.yaml
│       │   └── postgres.yaml  # PostgreSQL deployment + service
│       └── values.yaml
│
└── django/                  # Вихідний код Django + Dockerfile
```

---

## Передумови

- AWS CLI налаштований (`aws configure`)
- Встановлені: `terraform`, `kubectl`, `helm`
- GitHub токен (PAT) з правами `repo`

---

## Розгортання інфраструктури

### ⚠️ Перший запуск (bootstrapping) — обов'язково!

Існує класична проблема "курки та яйця": Terraform потребує S3-бакет для зберігання стейту, але сам S3-бакет створюється Terraform. Тому перший запуск відбувається у **3 етапи**:

**Етап 1: Закоментуй S3-бекенд**

Відкрий `backend.tf` і закоментуй весь блок:

```hcl
# terraform {
#   backend "s3" {
#     bucket         = "..."
#     ...
#   }
# }
```

**Етап 2: Створи тільки S3-бекенд і DynamoDB**

```bash
terraform init
terraform apply -target=module.s3_backend
```

_Це створить лише S3-бакет і DynamoDB-таблицю для зберігання стейту._

**Етап 3: Розкоментуй S3-бекенд і перенеси стейт у хмару**

Розкоментуй блок у `backend.tf`, потім:

```bash
terraform init
# Terraform запитає: "Do you want to migrate state?" → введи: yes
```

_Тепер стейт безпечно зберігається в AWS S3._

**Етап 4: Розгорни всю інфраструктуру**

```bash
terraform apply
```

_Terraform створить VPC, EKS, Jenkins, Argo CD і всі інші ресурси._

### 2. Підключення до кластера

```bash
aws eks update-kubeconfig --region eu-north-1 --name eks-cluster-demo-v2
```

### 3. Перевірка розгорнутих компонентів

```bash
# Всі поди системи
kubectl get pods -A

# Jenkins
kubectl get svc -n jenkins

# Argo CD
kubectl get svc -n argocd

# Django застосунок
kubectl get pods -n default
kubectl get svc -n default
```

---

## Налаштування секретів (перед першим apply)

Відкрий файл `modules/jenkins/values.yaml` і заміни:

```yaml
JCasC:
  configScripts:
    credentials: |
      credentials:
        system:
          domainCredentials:
            - credentials:
                - usernamePassword:
                    username: YOUR_GITHUB_USERNAME
                    password: "TODO: secret key here"  # ← вставити GitHub PAT
```

---

## Доступ до сервісів

### Jenkins

```bash
kubectl get svc -n jenkins
# Відкрий EXTERNAL-IP у браузері (порт 80)
# Login: admin / Password: admin123
```

### Argo CD

```bash
kubectl get svc -n argocd
# Відкрий EXTERNAL-IP у браузері

# Пароль адміністратора:
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

### Django застосунок

```bash
kubectl get svc -n default
# Відкрий EXTERNAL-IP (порт 80) у браузері
```

---

## Як запустити CI/CD пайплайн

1. Зайди в Jenkins UI
2. Запусти джобу **`seed-job`** → вона створить **`goit-django-docker`**
3. Затвердь скрипт: **Manage Jenkins → In-process Script Approval → Approve**
4. Запусти **`goit-django-docker`** → Jenkins збере образ, запушить в ECR і оновить тег
5. Argo CD автоматично виявить зміну і задеплоїть нову версію в Kubernetes

---

## Знищення інфраструктури

> ⚠️ **EKS Control Plane коштує ~$0.10/год.** Завжди видаляй ресурси після роботи!

```bash
terraform destroy
```

---

## Технічний стек

| Компонент             | Технологія                        |
| --------------------- | --------------------------------- |
| Інфраструктура як код | Terraform                         |
| Хмарний провайдер     | AWS (EKS, ECR, VPC, S3, DynamoDB) |
| Kubernetes            | Amazon EKS (`t3.small` nodes)     |
| CI (збірка образів)   | Jenkins + Kaniko                  |
| CD (деплой)           | Argo CD                           |
| Пакетний менеджер     | Helm                              |
| Застосунок            | Django + PostgreSQL               |
| Реєстр образів        | Amazon ECR                        |
