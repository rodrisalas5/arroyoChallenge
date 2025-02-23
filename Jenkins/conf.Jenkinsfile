pipeline {
    agent any

    stages {
        stage('Instalar Java 17') {
            steps {
                script {
                    sh '''
                        echo "**** Install java 17 ****"
                        apt-get update && \
                        apt-get install -y --no-install-recommends openjdk-17-jre && \
                        apt-get install ca-certificates-java -y && \
                        apt-get clean && \
                        update-ca-certificates -f

                        # Set JAVA_HOME environment variable
                        echo "JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/" | tee -a /etc/environment
                    '''
                }
            }
        }

        stage('Instalar Maven') {
            steps {
                script {
                    sh '''
                        echo "**** Install maven 3.9.9 ****"
                        curl -k -fsSL https://apache.osuosl.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz | tar xzf - -C /usr/share
                        mv /usr/share/apache-maven-3.9.9 /usr/share/maven
                        ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

                        # Set MAVEN_HOME environment variable
                        echo "MAVEN_HOME=/usr/share/maven" | tee -a /etc/environment
                    '''
                }
            }
        }

        stage('Verificar instalación') {
            steps {
                script {
                    sh '''
                        # Verificar que Java y Maven se instalaron correctamente
                        java -version
                        mvn -v
                    '''
                }
            }
        }
        
        stage('Instalar Terraform') {
            steps {
                script {
                    sh '''
                        echo "**** Install Terraform ****"
                        # Descargar la versión más reciente de Terraform
                        curl -fsSL https://releases.hashicorp.com/terraform/1.4.0/terraform_1.4.0_linux_amd64.zip -o /tmp/terraform.zip

                        # Instalar Terraform
                        unzip /tmp/terraform.zip -d /usr/local/bin
                        rm /tmp/terraform.zip
                        terraform -v
                    '''
                }
            }
        }
    }
}
