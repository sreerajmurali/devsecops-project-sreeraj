pipeline {
    agent any

    environment {
        MAVEN_OPTS = '--add-opens java.base/java.lang=ALL-UNNAMED'
        DOCKER_IMAGE = "sreerajmurali/numeric-app"
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
                script {
                    def commitId = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    sh 'printenv'
                    sh "docker build -t ${DOCKER_IMAGE}:${commitId} ."
                    sh "docker push ${DOCKER_IMAGE}:${commitId}"
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}