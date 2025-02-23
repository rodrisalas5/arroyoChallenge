# arroyoChallenge
Repositorio para entrevista técnica - Arroyo. 

---

# Descripción y requisitos: 

1. Crear un servicio de cómputo con SO Linux (EC2, ECS, EKS, etc…).
2. Crear un servicio de base de datos (RDS, DynamoDB, Aurora, etc …).
3. Crear políticas de seguridad para el acceso SSH (por ejemplo, restricción de IPs).
4. Construir una imagen de Docker con SO Linux y publicarla, la imagen debe contar con las siguientes especificaciones:
- Instalar Git
- Instalar Vs Code
- Instalar Maven
- Instalar PostgreSQL
- Instalar Java JRE
- Debe poder compilar proyectos NetCore
- Debe poder compilar aplicaciones Java
- Subir un servidor apache con un “hola mundo” o cualquier proyecto público.
- Montar la imagen de Docker creada en el servicio de computo elegido en el paso 1

### NOTA:

- Debe haber conexión entre el Docker y el servicio de base de datos elegido.
- Debe ser elaborado en una cuenta propia (debe explorar sus opciones).
- Concedernos acceso a la imagen de Docker publicada.
- Concedernos acceso a los archivos de Terraform creados.
- Justificar por qué el tipo de servicio de cómputo y base de datos elegidos.
- Es un plus cualquier configuración adicional realizada.
- Explicarnos como la prueba sera ejecutado (Manualmente or con un pipeline).
- Explique el uso y gestion del state file y donde esta almacenado.
- Explique la gestion del archive .lock en Terraform para esta evaluación.
- Para la entrega del reto, no es necesario tener los recursos desplegados en la nube de AWS, de nuestro lado necesitamos solo acceso al repo de GitHub por ejemplo o enviarnos un archivo comprimido con la solución completa.


**Fecha límite:** Lunes 24 de Febrero de 2025.
---

Para la siguiente prueba técnica se detallarán los paso a paso para poder realizar los requirimientos de la misma. También, se agregará información extra para buenas prácticas. 

El repositorio dónde se detallará la entrevista es: [Repositorio](https://github.com/rodrisalas5/arroyoChallenge)

A su vez, se agregarán diagramas y justificaciones sobre las decisiones tomadas para la realización de los requisitos. 

1. Se ha decidido utilizar Terraform para desplegar la infraestructura cómo código. Se ha decidido optar por una instancia EC2 ya que es capaz:

- Contener Docker
- Pullear imagen desde ECR (Elastic Container Registry)
- Levantar aplicación Java para "Hola mundo"
- Costos reducidos
- Cuenta con AMI de sistema operativo Linux
- Se puede ejecutar un init script para la configuración inicial

Sin dudas, para este caso no tiene "sentido" levantar un clúster para una aplicación monolito y que no es un micro servicio. Si bien Kubernetes nos permite mayor escalabildiad y flexibilidad con una instancia EC2 logramos: 

- Escalar verticalmente (subiendo el type de la instancia, por ejemplo, de t2.micro a t2.2xlarge)
- Escalar horizontalmente (deployando nuevas intancias que puedan ser administradas por un, por ejemplo, un load balancer para distruir la carga)

Si a futuro, nuestra aplicación crece no existe duda alguna que se debería migrar a un orquestador. En dicho caso, se sugieran las siguientes recomendaciones:

- Elastic Container Service ya que es del tipo fargate y la administración de nuestro clúster se encarga AWS
- Del punto anterior se desprende que AWS también nos otorga servicios si no contamos con experiencia en Kubernertes
- Si el equipo cuenta con experiencia, la mejor opción a futuro sería contar un Elastic Kubernetes Service 

Respecto a base de datos se ha optado por RDS MySql por:

- Permite escalar verticalmente
- Permite escalar horizontalmente
- Comunidad activa por problemas
- Alta disponibilidad, multi AZ
- Automatización de copias de seguridad
- Monitoreo
- Pago por uso
- Integración con demás servicios de AWS, por ejemplo, EC2

### Mediante Terraform buscamos la siguente arquitectura: 

![Arquitectura](/Img/arq.drawio.svg)

Teniendo en cuenta:

- EC2 accesible desde internet
- RDS accesible solo desde EC2 y no desde el exterior
- Acceso SSH a EC2

### Comandos 

**Terraform**
```
terraform init

terraform fmt

terraform plan -var-file="secrets.tfvars"

terraform apply -var-file="secrets.tfvars"
```

![Comandos](/Img/terraform.drawio.svg)


**Conexión SQL**
```
mysql -h <database-endpoint> -P <database-port> -u <db-username> -p
```

![Conexión](/Img/sql.drawio.svg)


## Manejo de archivos Terraform State

Para el manejo de nuestro state se decide subirlo a un Bucket S3 con configuración en Dynamo DB para nuestro .lock. De esta manera: 

- No se pueden ejecutar cambios en simultáneo 
- Mejor estructura
- Centralización
- Versionado
- Automatización

Por una cuestión de separación se ha decidido agregar un modulo para separar la configuración realizada. Podemos observar al ejecutar nuestro comando "terraform plan" que se crean nuevos servicios.

![Conexión](/Img/tfstate.drawio.svg)

## Consideraciones finales sobre Terraform

- Se podría mejorar mucho más aún la estructura de nuestros ficheros, por ejemplo, separando en módulos y de esa manera poder tener archivos de variables y output po diferentes módulos. Por cuestión de tiempos, no se realiza para la PoC en curso
- Se podría generar una AMI propia que se ajuste mejor a nuestros requimientos
- La aplicación de nuestra arquitectura generará las claves necesarias para conectarnos a nuestra instancia EC2
- Se podría tomar la imagen desde ECR para mejor manero de un registry desde AWS (centralización de servicios, útil si después utilizamos ECS)
- Se configurará la instancia de forma inicial al ejecutar el userdata, permite correr comandos en nuestra máquina virtual para poder configurarla

## Configuración AWS Profile 

- Permite configurar el profile directamente en el provider de AWS (main.tf)

Se debe configurar bajo nuestra carpeta .aws 

![AWS](/Img/aws.drawio.svg)

--- 

### Armado de Dockerfile

**Comandos:**

Me posiciono sobre directorio donde se encuentra el Dockerfile --> Build\Dockerfile
```
docker build -t [nombre/tag] .
```

![Build](/Img/dockerBuild.drawio.svg)

Para correr la imagen exponiendo el puerto 8080
```
docker run -d -p 8080:8080 arroyo
```

Para ingresar al contenedor y corroborar los requisitos que se necesitaban para la instalación
```
docker ps
```
Luego de obtener el container ID
```
docker exec -it [CONTAINER ID] bash
```

### Verificación de imagen con: 

- Git
- VSC
- Java
- MVN
- NetCore
- PSQL

![Apps](/Img/dockerApps.drawio.svg)

### Notas Dockerfile

- Dentro de build contenemos la aplicación de "Hello World", Java en un servidor de aplicaciones TomCat
- Apache-conf contiene los archivos necesarios para poder ingresar a TomCat desde otro servidor y las credenciales para hacerlo
- No se recomienda un Dockerfile tan largo, solo por requisito se hace de esta manera. Una buena práctica, es dividir la imagen y por "stage" llamar a dichas imágenes con cláusula "from". 

--- 

### Aplicación "Hello World" funcionando

![App](/Img/App.drawio.svg)

---

### Push imagen a registry público

![Registry](/Img/dockerPush.drawio.svg)

**Registry:** [Docker Hub](https://hub.docker.com/repository/docker/rodrisalas5/arroyo/general)

**Descargar la imagen**
```
docker push rodrisalas5/arroyo:tagname
```

--- 

### Automatización con Jenkins

Para correr Jenkins mediante Docker:

```
docker run -d -v jenkins_home:/var/jenkins_home -p 8080:8080 -p 50000:50000 --restart=on-failure jenkins/jenkins:lts-jdk17

docker run -d \
  -v jenkins_home:/var/jenkins_home \
   \
  -p 8080:8080 \
  -p 50000:50000 \
  --restart=on-failure \
  jenkins/jenkins:lts-jdk17

```

Para cumplir los requirimientos de automatización, se utilizará un solo Jenkins. Si el proyecto escala, siempre se recomienda la utilización de Slaves para no sobrecargar al Jenkins Master.