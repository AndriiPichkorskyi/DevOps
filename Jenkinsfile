pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: jenkins-kaniko
spec:
  serviceAccountName: jenkins-sa
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.16.0-debug
      imagePullPolicy: Always
      command:
        - sleep
      args:
        - 99d
    - name: git
      image: alpine/git
      command:
        - sleep
      args:
        - 99d
"""
    }
  }

  environment {
    // AWS ECR репозиторій
    ECR_REGISTRY = "891377024254.dkr.ecr.eu-north-1.amazonaws.com"
    IMAGE_NAME   = "lesson-5-ecr"
    IMAGE_TAG    = "v1.0.${BUILD_NUMBER}"

    COMMIT_EMAIL = "jenkins@localhost"
    COMMIT_NAME  = "jenkins"
  }

  stages {
    stage('Build & Push Docker Image') {
      steps {
        container('kaniko') {
          sh '''
            /kaniko/executor \
              --context `pwd` \
              --dockerfile `pwd`/Dockerfile \
              --destination=$ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG \
              --cache=true \
              --insecure \
              --skip-tls-verify
          '''
        }
      }
    }

    stage('Update Chart Tag in Git') {
      steps {
        container('git') {
          withCredentials([usernamePassword(credentialsId: 'github-token', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PAT')]) {
            sh '''
              # Клонуємо репозиторій
              git clone "https://${GIT_USERNAME}:${GIT_PAT}@github.com/AndriiPichkorskyi/DevOps.git"
              cd DevOps
              
              git checkout lesson-4

              # Міняємо тег у чарті
              sed -i "s/tag: .*/tag: $IMAGE_TAG/" charts/django-app/values.yaml

              git config user.email "$COMMIT_EMAIL"
              git config user.name "$COMMIT_NAME"

              git add charts/django-app/values.yaml
              git commit -m "Update image tag to $IMAGE_TAG"
              
              git push origin lesson-4
            '''
          }
        }
      }
    }
  }
}
