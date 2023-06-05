pipeline {
  agent any
  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub-cred')
    DOCKERHUB_USERNAME = "19269506"
    APP_NAME = "postgres-demo"
    IMAGE_TAG = "${BUILD_NUMBER}"
    IMAGE_NAME = "${DOCKERHUB_USERNAME}" + "/" + "${APP_NAME}"
  }
  tools {
    maven 'Maven'
  }
  stages {
    stage('Build Project') {
      steps {
        checkout([
          $class: 'GitSCM',
          branches: [
            [name: 'master']
          ],
          doGenerateSubmoduleConfigurations: false,
          extensions: [
            [$class: 'CleanCheckout']
          ],
          submoduleCfg: [],
          userRemoteConfigs: [
            [url: 'https://github.com/nhandn-devops/postgres-demo.git']
          ]
        ])
        sh 'mvn clean install -DskipTests=true'
      }
    }
    stage('Build docker image') {
      steps {
        script {
          sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
          sh 'docker build -t ${IMAGE_NAME} .'
        }
      }
    }
    stage('Login and push image to dockerhub') {

      steps {
        sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
        sh 'docker push ${IMAGE_NAME}:${IMAGE_TAG}'
        sh 'docker push ${IMAGE_NAME}:latest'
        sh 'docker image rm -f ${IMAGE_NAME}:${IMAGE_TAG}'
        sh 'docker image rm -f ${IMAGE_NAME}:latest"'
      }
    }
    stage('Updating Kubernetes deployment file') {
      steps {
        sh "cat k8s/deployment.yml"
        sh "sed -i 's/${APP_NAME}.*/${APP_NAME}:${IMAGE_TAG}/g' k8s/deployment.yml"
        sh "cat deployment.yml"
      }
    }

    stage('Push the changed deployment file to Git') {
      steps {
        script {
          sh 'git config--global user.name "nhanduongn"'
          sh 'git config--global user.email "nhanduongn2000@gmail.com"'
          sh 'git add deployment.yml'
          sh 'git commit - m "Updated the deployment file"'
          withCredentials([usernamePassword(credentialsId: 'github', passwordVariable: 'pass', usernameVariable: 'user')]) {
            sh 'git push http://$user:$pass@github.com/nhandn-devops/postgres-demo.git master'
          }
        }
      }
    }
  }
  post {
    always {
      sh 'docker logout'
    }
  }
}