pipeline {
  agent any

  stages {
    stage('Build Artifact') {
      steps {
        sh 'mvn clean package -DskipTests=true -DargLine="--add-opens java.base/java.lang=ALL-UNNAMED"'
        archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
      }
    }
  }
}