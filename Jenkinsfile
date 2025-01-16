pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    sh 'mvn clean package -DskipTests=true -DargLine="--add-opens java.base/java.lang=ALL-UNNAMED"'
                }
            }
        }
    }
}