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
                    sh "docker build --no-cache -t ${IMAGE_NAME} ."
                }
            }
        }

        stage('Run API Container') {
            steps {
                script {
                    sh "docker rm -f ${CONTAINER_NAME} || true"
                    sh "docker run -d --name ${CONTAINER_NAME} -p 8000:8000 ${IMAGE_NAME}"

                    echo "Attente que l'API soit disponible sur http://localhost:8000..."
                    timeout(time: 30, unit: 'SECONDS') {
                        waitUntil {
                            script {
                                def response = sh(
                                    script: "curl -s -o /dev/null -w '%{http_code}' http://localhost:8000/ || echo '000'",
                                    returnStdout: true
                                ).trim()
                                echo "HTTP Status: ${response}"
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
                    // Lancer un container pour exécuter les tests avec accès au réseau hôte
                    sh """
                    docker run --rm --network host \
                        -v \$(pwd):/app -w /app \
                        ${IMAGE_NAME} python3 tests/selenium_test.py
                    """
                }
            }
        }

        stage('PMD Analysis') {
            steps {
                script {
                    // Assure-toi d'avoir un ruleset PMD compatible si tu utilises Python !
                    sh """
                    docker run --rm -v \$(pwd):/src ctsd/pmd \
                    pmd-bin-6.52.0/bin/run.sh pmd \
                    -d /src/app -R rulesets/java/quickstart.xml -f text
                    """
                }
            }
        }
    }

    post {
        always {
            script {
                // Voir les logs pour debug si besoin
                sh "docker logs ${CONTAINER_NAME} || true"
                // Nettoyage
                sh "docker rm -f ${CONTAINER_NAME} || true"
            }
        }
    }
}
