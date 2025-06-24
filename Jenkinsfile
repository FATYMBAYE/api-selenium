pipeline {
    agent any

    environment {
        IMAGE_NAME = "tp3-api"
        CONTAINER_NAME = "tp3-api-container"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME} ."
                }
            }
        }

        stage('Run API Container') {
            steps {
                script {
                    // Stoppe un conteneur éventuel du même nom
                    sh "docker rm -f ${CONTAINER_NAME} || true"
                    // Lance le container en arrière-plan
                    sh "docker run -d --name ${CONTAINER_NAME} -p 8000:8000 ${IMAGE_NAME}"
                    // Attendre que l’API soit disponible (timeout 30s)
                    timeout(time:30, unit:'SECONDS') {
                        waitUntil {
                            script {
                                def response = sh(script: "curl -s -o /dev/null -w '%{http_code}' http://localhost:8000/", returnStdout: true).trim()
                                return (response == '200')
                            }
                        }
                    }
                }
            }
        }

        stage('Run Selenium Tests') {
            steps {
                script {
                    sh "docker exec ${CONTAINER_NAME} python3 tests/selenium_test.py"
                }
            }
        }

        stage('PMD Analysis') {
            steps {
                script {
                    // Ici tu lances PMD sur ton code Java (adapter selon ton projet)
                    // Exemple d’appel via un container docker PMD (avec le volume)
                    sh """
                        docker run --rm -v \$(pwd):/src ctsd/pmd pmd-bin-6.52.0/bin/run.sh pmd -d /src/app -R rulesets/java/quickstart.xml -f text
                    """
                }
            }
        }
    }

    post {
        always {
            script {
                // Nettoyage : arrêter et supprimer le container
                sh "docker rm -f ${CONTAINER_NAME} || true"
            }
        }
    }
}
