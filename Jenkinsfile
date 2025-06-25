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
                    // Construire l'image Docker à partir du Dockerfile à la racine
                    sh "docker build -t ${IMAGE_NAME} ."
                }
            }
        }

        stage('Run API Container') {
            steps {
                script {
                    // Stopper un conteneur du même nom s'il existe
                    sh "docker rm -f ${CONTAINER_NAME} || true"
                    // Lancer le container en arrière-plan, expose le port 8000
                    sh "docker run -d --name ${CONTAINER_NAME} -p 8000:8000 ${IMAGE_NAME}"
                    // Attendre que l'API réponde sur localhost:8000 (timeout 30s)
                    timeout(time: 30, unit: 'SECONDS') {
                        waitUntil {
                            script {
                                // On utilise localhost car Jenkins et Docker sur la même machine
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
                    // Exécuter le test Selenium **depuis Jenkins**, pas depuis le container de l'API
                    // car Selenium doit être lancé dans un container séparé (avec Chrome/ChromeDriver)
                    // Ici il faut plutôt lancer un container dédié aux tests Selenium
                    sh """
                    docker run --rm --network host -v \$(pwd):/app -w /app ${IMAGE_NAME} \
                    python3 tests/selenium_test.py
                    """
                }
            }
        }

        stage('PMD Analysis') {
            steps {
                script {
                    // Lancer PMD via docker (adapter selon langage)
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
                // Nettoyage : arrêter et supprimer le container si il tourne encore
                sh "docker rm -f ${CONTAINER_NAME} || true"
            }
        }
    }
}
