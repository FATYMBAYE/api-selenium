pipeline {
    agent any

    environment {
        IMAGE_NAME = 'tp3-api'
        CONTAINER_NAME = 'tp3-api-container'
        API_URL = 'http://host.docker.internal:8000/health'  // <-- adapte cette URL selon ta vraie route de santé
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker image') {
            steps {
                echo 'Build de l’image Docker...'
                sh 'docker build -t ${IMAGE_NAME}:latest .'
            }
        }

        stage('Run API container') {
            steps {
                echo 'Lancement du container API...'
                sh 'docker rm -f ${CONTAINER_NAME} || true'
                sh 'docker run -d --name ${CONTAINER_NAME} -p 8000:8000 ${IMAGE_NAME}:latest'

                echo 'Vérification que l’API est prête depuis Jenkins container...'
                script {
                    retry(10) {
                        def code = sh(
                            script: "curl -L -s -o /dev/null -w \"%{http_code}\" ${API_URL}",
                            returnStdout: true
                        ).trim()
                        if (code != '200') {
                            echo "API non prête, code HTTP : ${code}. Nouvelle tentative dans 2 secondes..."
                            sleep 2
                            error("API non prête")
                        }
                        echo "API prête avec code HTTP 200."
                    }
                }
            }
        }

        stage('Run unit tests') {
            steps {
                echo 'Exécution des tests unitaires...'
                sh "docker exec ${CONTAINER_NAME} pytest tests/"
            }
        }

        stage('Run Selenium tests') {
            steps {
                echo 'Exécution des tests Selenium...'
                sh "docker exec ${CONTAINER_NAME} python tests/selenium_test.py"

            }
        }

        stage('SonarQube analysis') {
            environment {
                SONAR_TOKEN = credentials('sonar-token')
            }
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        sonar-scanner \
                        -Dsonar.projectKey=tp3-api \
                        -Dsonar.sources=app \
                        -Dsonar.host.url=$SONAR_HOST_URL \
                        -Dsonar.login=$SONAR_TOKEN
                    '''
                }
            }
        }
    }

    post {
        always {
            echo 'Nettoyage...'
            sh 'docker rm -f ${CONTAINER_NAME} || true'
        }
        success {
            echo 'Pipeline terminé avec succès !'
        }
        failure {
            echo 'Pipeline échoué.'
        }
    }
}
