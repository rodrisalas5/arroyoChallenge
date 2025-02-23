pipeline {
    agent any

    stages {
        stage('Clone Repo') {
            steps {
                script {
                    // Verificar si el repositorio ya está clonado
                    def repoDir = 'arroyoChallenge'
                    if (!fileExists(repoDir)) {
                        sh "git clone https://github.com/rodrisalas5/arroyoChallenge.git"
                    } else {
                        echo "El repositorio ya está clonado."
                    }
                }
            }
        }
        stage('Build Project') {
            steps {
                script {
                    // Cambiar al directorio del proyecto
                    sh "cd arroyoChallenge/Build/Java-app && mvn clean install -U && mvn clean package -e"
                }
            }
        }
    }
}