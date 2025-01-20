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
               sh 'docker build -t sreerajmurali/numeric-app:""$GIT_COMMIT"" .'
            }
          }
        
        // stage('Debug') {
        // steps {
        // sh 'echo "GIT_COMMIT: ${GIT_COMMIT}"'
        //       }
        //  }  

         
        stage('Docker Push') {
            steps {
               withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
              sh 'docker push sreerajmurali/numeric-app:""$GIT_COMMIT""'
              }
             }
          }
        stage('Kubernetes Deployment - DEV') {
            steps {
              withKubeConfig([credentialsId: 'kubeconfig']) {
                sh "sed -i 's#replace#sreerajmurali/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                sh "kubectl apply -f k8s_deployment_service.yaml"
        }
      }
    }
  }
}
