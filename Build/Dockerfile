FROM ubuntu:latest

# Actualizar los paquetes e instalar las dependencias necesarias
RUN apt-get update && apt-get install -y \
    curl \
    gnupg \
    lsb-release \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
##############################################################################################################################################################
### Instalación de Git 
##############################################################################################################################################################
    git \
##############################################################################################################################################################
### Instalación de cliente SQL para que el contenedor pueda conectarse al RDS de AWS 
##############################################################################################################################################################
    mysql-client

##############################################################################################################################################################
### Instalación VSC
##############################################################################################################################################################
RUN echo "**** Install VSCode ****"
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg \
    && sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'


### show available vscode versions
RUN echo "vs-code versions:" && apt-cache policy code

### Install vscode in the specifc version
RUN apt-get update && apt-get install -y code=1.88.1-1712771838 \
    && apt-get install -f
##############################################################################################################################################################


##############################################################################################################################################################
### Instalación Java y Maven
##############################################################################################################################################################
RUN echo "**** Install java 17 ****"
RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-17-jre && \
    apt-get install ca-certificates-java -y && \
    apt-get clean && \
    update-ca-certificates -f;

# Set env vars
RUN  export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64/"

RUN echo "**** Install maven 3.9.9 ****"
RUN curl -k -fsSL https://apache.osuosl.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz | tar xzf - -C /usr/share && \
    mv /usr/share/apache-maven-3.9.9 /usr/share/maven && \
    ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

RUN export MAVEN_HOME="/usr/share/maven"
##############################################################################################################################################################


##############################################################################################################################################################
### Instalación PSQL
##############################################################################################################################################################
RUN apt-get install postgresql -y
##############################################################################################################################################################


##############################################################################################################################################################
### Instalación NetCore
##############################################################################################################################################################
RUN apt-get update \
    && apt-get install -y wget \
    && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install -y libicu-dev apt-transport-https
RUN wget https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb
RUN apt-get update
RUN apt-get install -y dotnet-sdk-8.0
##############################################################################################################################################################


##############################################################################################################################################################
### Instalación TomCat
##############################################################################################################################################################
RUN mkdir /usr/local/tomcat
RUN wget https://downloads.apache.org/tomcat/tomcat-10/v10.1.35/bin/apache-tomcat-10.1.35.tar.gz -O /tmp/tomcat.tar.gz
RUN cd /tmp && tar xvfz tomcat.tar.gz
##############################################################################################################################################################


##############################################################################################################################################################
### Instalación proyecto "Hello World"
##############################################################################################################################################################
COPY ./Java-app/helloworld/target/hello-world.war /tmp/apache-tomcat-10.1.35/webapps/hello-world.war
COPY Apache-conf/tomcat-users.xml /tmp/apache-tomcat-10.1.35/conf/tomcat-users.xml
COPY Apache-conf/context.xml /tmp/apache-tomcat-10.1.35/webapps/manager/META-INF/context.xml
##############################################################################################################################################################

# Exponer el puerto 8080 para acceder a la aplicación 
EXPOSE 8080

# Comando por defecto
CMD ["/tmp/apache-tomcat-10.1.35/bin/catalina.sh", "run"]