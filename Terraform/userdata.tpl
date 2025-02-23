#!/bin/bash

# Instalar Docker
sudo apt update
sudo apt install software-properties-common ca-certificates curl gnupg-agent apt-transport-https
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
# Permiso necesario para Docker
sudo usermod -aG docker user

# Instalar cliente MySQL para conectarnos al RDS
sudo apt-get update -y && sudo apt install mysql-client -y

# Descargar la imagen
docker push rodrisalas5/arroyo:latest

# Correr el contenedor en la instancia Linux
docker run -d -p 8080:8080 arroyo