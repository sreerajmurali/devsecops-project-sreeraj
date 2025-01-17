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
        stage('Docker Build and Push') {
            steps {
                // withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
                    sh 'echo "Environment Variables:"'
                    sh 'printenv'
                    sh 'echo "Docker Info:"'
                    sh 'docker info'
                    sh 'echo "Building Docker Image:"'
                    sh 'sudo docker build -t sreerajmurali/numeric-app:""$GIT_COMMIT"" .'
                    sh 'echo "Pushing Docker Image:"'
                    sh 'sudo docker push sreerajmurali/numeric-app:""$GIT_COMMIT""'
        }
      }
    }
  }
}