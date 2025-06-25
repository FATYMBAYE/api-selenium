pipeline {
    agent any

    environment {
        IMAGE_NAME = 'tp3-api'
        CONTAINER_NAME = 'tp3-api-container'
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
                sh 'docker run -d --name ${CONTAINER_NAME} ${IMAGE_NAME}:latest'

                echo 'Vérification que l’API est prête depuis le container...'
                sh '''
                for i in {1..10}; do
                  code=$(docker exec ${CONTAINER_NAME} curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/)
                  if [ "$code" = "200" ]; then
                    echo "API prête avec HTTP 200."
                    exit 0
                  fi
                  echo "Tentative $i : HTTP $code. Nouvelle tentative dans 2s..."
                  sleep 2
                done
                echo "Erreur : l’API n’a pas répondu correctement après 10 tentatives."
                exit 1
                '''
            }
        }

        stage('Run unit tests') {
            steps {
                echo 'Exécution des tests unitaires...'
                sh 'docker exec ${CONTAINER_NAME} pytest tests/'
            }
        }

        stage('Run Selenium tests') {
            steps {
                echo 'Exécution des tests Selenium...'
                sh 'docker exec ${CONTAINER_NAME} python selenium_test.py'
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
