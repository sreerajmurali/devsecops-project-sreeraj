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
        
        stage('Docker Push') {
            steps {
               withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
               sh 'docker push sreerajmurali/numeric-app:""$GIT_COMMIT""'
              }
             }
          }
      }   
}
