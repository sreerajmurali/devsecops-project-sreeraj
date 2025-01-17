pipeline {
    agent any

    environment {
        MAVEN_OPTS = '--add-opens java.base/java.lang=ALL-UNNAMED'
    }

    stages {
        stage('Build Artifact') {
            steps {
                sh 'mvn clean package -DskipTests=true'
                archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
            }
        }
        
        stage('Unit Tests - JUnit and Jacoco') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                    jacoco execPattern: 'target/jacoco.exec'
                }
            }
        }
        
        stage('Docker Build') {
            steps {
               sh 'sudo docker build -t sreerajmurali/numeric-app:""$GIT_COMMIT"" .'
            }
          }
        
        stage('Debug') {
        steps {
        sh 'echo "GIT_COMMIT: ${GIT_COMMIT}"'
              }
         }  

    stage('Docker Login and Push') {
    steps {
        script {
            withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: sreerajmurali, passwordVariable: password123)]) {
                sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                sh 'docker push sreerajmurali/numeric-app:${GIT_COMMIT}'
            }
        }
    }
}
        
      }   
}
