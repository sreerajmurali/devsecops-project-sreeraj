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
                script {
                    sudo docker.build('sreerajmurali/numeric-app')
                }
            }
        }
        
        stage('Docker Push') {
            steps {
                script {
                    withDockerRegistry([credentialsId: 'docker-hub', url: '']) {
                        docker.image('sreerajmurali/numeric-app').push('latest')
                    }
                }
            }
        }
    }
}