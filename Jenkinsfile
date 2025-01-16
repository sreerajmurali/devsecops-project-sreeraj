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
  }
}