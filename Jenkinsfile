pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              //sh "mvn clean package -DskipTests=true"
              sh "mvn clean package -DskipTests=true" -DargLine="--add-opens java.base/java.lang=ALL-UNNAMED"

              archive 'target/*.jar' //so that they can be downloaded later
            }
        }   
    }
}