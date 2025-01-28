pipeline {
    agent any

    environment {
        MAVEN_OPTS = '--add-opens java.base/java.lang=ALL-UNNAMED'
        deploymentName = "devsecops"
        containerName = "devsecops-container"
        serviceName = "devsecops-svc"
        imageName = "sreerajmurali/numeric-app:${GIT_COMMIT}"
        //applicationURL = "http://devsecops-demo.eastus.cloudapp.azure.com/"
        applicationURL = "http://devsecops-cloudvm2.eastus.cloudapp.azure.com"
        applicationURI = "/increment/99"
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

        stage('Mutation Tests - PIT') {
            steps {
                sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
            post {
                always {
                    pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
                }
            }
        }

        stage('SonarQube - SAST') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh "mvn sonar:sonar -Dsonar.projectKey=numeric-application -Dsonar.host.url=http://devsecops-cloudvm2.eastus.cloudapp.azure.com:9000"
                }
                timeout(time: 2, unit: 'MINUTES') {
                    script {
                        waitForQualityGate abortPipeline: true
                    }
                } 
            }
        }
        
        stage('Vulnerability Scan - Docker') {
            steps {
                parallel (
                    "Dependency Check": {
                        script {
                            try {
                                sh "mvn dependency-check:check"
                            } catch (Exception e) {
                                echo 'Ignoring vulnerabilities found in Dependency Check.'
                                currentBuild.result = 'SUCCESS' // or 'UNSTABLE' if you prefer
                            }
                        }
                    },
                    "Trivy Scan": {
                          sh "bash trivy-docker-image-scan.sh"
                    },
                    "OPA Conftest": {
                          sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
                    }
                )
            }
            post {
                always {
                    dependencyCheckPublisher pattern: 'target/dependency-check-report.xml', failedTotalCritical: 0, unstableTotalCritical: 10
                }
            }
        }

        stage('Docker Build and Push') {
            steps {
                withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
                    sh 'printenv'
                    sh 'sudo docker build -t sreerajmurali/numeric-app:${GIT_COMMIT} .'
                    sh 'docker push sreerajmurali/numeric-app:${GIT_COMMIT}'
                }
            }
        }

        stage('Vulnerability Scan - Kubernetes') {
            steps {
                parallel(
                    "OPA Scan": {
                        sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
                    },
                    "Kubesec Scan": {
                        sh "bash kubesec-scan.sh"
                    },
                    "Trivy Scan": {
                        script {
                            try {
                                sh "bash trivy-k8s-scan.sh"
                            } catch (Exception e) {
                                echo 'Ignoring vulnerabilities found in Trivy Kubernetes Scan.'
                                currentBuild.result = 'SUCCESS'
                            }
                        }
                    }
                )
            }
        }

        stage('K8S Deployment - DEV') {
            steps {
                parallel(
                    "Deployment": {
                        withKubeConfig([credentialsId: 'kubeconfig']) {
                            sh "bash k8s-deployment.sh"
                        }
                    },
                    "Rollout Status": {
                        withKubeConfig([credentialsId: 'kubeconfig']) {
                            sh "bash k8s-deployment-rollout-status.sh"
                        }
                    }
                )
            }
        }

        stage('Integration Tests - DEV') {
            steps {
                script {
                    try {
                        withKubeConfig([credentialsId: 'kubeconfig']) {
                            sh "bash integration-test.sh"
                        }
                    } catch (Exception e) {
                        withKubeConfig([credentialsId: 'kubeconfig']) {
                            sh "kubectl -n default rollout undo deploy ${deploymentName}"
                        }
                        throw e
                    }
                }
            }
        }
    //    stage('OWASP ZAP - DAST') {
    //         steps {
    //             withKubeConfig([credentialsId: 'kubeconfig']) {
    //             sh 'docker pull ghcr.io/zaproxy/zaproxy:weekly'
    //             sh 'docker run -v $(pwd):/zap/wrk/:rw -t ghcr.io/zaproxy/zaproxy:weekly zap.sh'
    //             // sh 'bash zap.sh'
    //     }
    //   }
    // }
 stage('OWASP ZAP - DAST') {
    steps {
        withKubeConfig([credentialsId: 'kubeconfig']) {
            sh 'docker pull ghcr.io/zaproxy/zaproxy:weekly'
            sh 'docker run -d --name zap_dast -v $(pwd):/zap/wrk/:rw -u zap -t ghcr.io/zaproxy/zaproxy:weekly zap.sh -daemon -host 0.0.0.0 -port 8080 -config api.disablekey=true'
            sh 'sleep 20' // Increase sleep time to give ZAP more time to start
            sh 'docker exec zap_dast zap-baseline.py -t http://devsecops-cloudvm2.eastus.cloudapp.azure.com:31456 -r /zap/wrk/zap_report.html --autooff -T 20'
            sh 'docker stop zap_dast'
            sh 'docker rm zap_dast'
        }
    }
}
    }

    post {
        always {
            junit 'target/surefire-reports/*.xml'
            jacoco execPattern: 'target/jacoco.exec'
            pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
            //dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
            publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'OWASP ZAP HTML Report', reportTitles: 'OWASP ZAP HTML Report'])

        }
    }
}