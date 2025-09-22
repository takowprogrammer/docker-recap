# student-list 
This repository is a simple application for listing students with a web server (PHP) and an API (Flask).

![project](https://user-images.githubusercontent.com/18481009/84582395-ba230b00-adeb-11ea-9453-22ed1be7e268.jpg)


------------


## Objectives

The objectives of this practical project are to ensure that you are capable of managing a Docker infrastructure. 

### Themes:
- Improve the deployment process of an existing application
- Version your infrastructure releases
- Address best practices when implementing a Docker infrastructure
- Infrastructure as Code

## Context

POZOS is an IT company located in France that develops software for high schools.

The innovation department wants to revolutionize the existing infrastructure to ensure it can be scalable, easily deployable, and maximized in terms of automation.

POZOS asks you to build a "POC" (Proof of Concept) to show how Docker can help them and how effective this technology is.

For this POC, POZOS will provide you with an application and wants you to build a "decoupled" infrastructure based on "Docker".

Currently, the application runs on a single server, without scalability or high availability.

Every time POZOS needs to deploy a new version, something goes wrong.

In conclusion, POZOS needs agility in their software farm.


## Infrastructure

For this POC, you will only use a single machine with Docker installed on it.

The build and deployment will be done on this machine.

POZOS recommends that you use the CentOS 7.6 operating system as it is the most used in the company.

Please also note that you are authorized to use a virtual machine based on CentOS 7.6 and not your physical machine.

Security is a very critical aspect for POZOS IT department, so please do not disable the firewall or other security mechanisms. Otherwise, please explain your reasons in your delivery.

## Application


The application you will work on is called "*student_list*". This application is very basic and allows POZOS to display the list of students with their age.

student_list has two modules:

- The first module is a REST API (with basic authentication required) that sends the desired list of students based on a JSON file.
- The second module is a web application written in HTML + PHP that allows the end user to get a list of students.

Your work consists of building a container for each module and making them interact with each other.

The application source code can be found [here](https://github.com/nzapanarcisse/docker-datascientest-recap.git).

The files you need to provide (in your delivery) are ***Dockerfile*** and ***docker-compose.yml*** (currently, both are empty).

Now, it's time to explain the role of each file:

- **docker-compose.yml**: to launch the application (API and web application)
- **Dockerfile**: the file that will be used to build the API image (details will be provided)
- **requirements.txt**: contains all the packages to install to make the application work
- **student_age.json**: contains the names of students with their age in JSON format
- **student_age.py**: contains the Python API source code
- **index.php**: PHP page where the end user will connect to interact with the service to list students with their age. You must update the following line before launching the website container to adapt ***api_ip_or_name*** and ***port*** to your deployment:

```bash
$url = 'http://<api_ip_or_name:port>/pozos/api/v1.0/get_student_ages';




```

## Docker Registry

POZOS needs you to deploy a private registry and store the built images.

You must therefore deploy:

- a [Docker registry](https://docs.docker.com/registry/ "registry")
- a [web interface](https://hub.docker.com/r/joxit/docker-registry-ui/ "interface") to see the pushed images as containers.

Or you can use [Portus](http://port.us.org/ "Portus") to run both.

Don't forget to push your image to your private registry and show them in your delivery.


# PROPOSED SOLUTION

mkdir mini-projet-docker 
cd mini-projet-docker then git clone https://github.com/nzapanarcisse/docker-datascientest-recap.git

```bash
cd simple_api
docker build . -t api-pozos:1
```
![image](https://github.com/user-attachments/assets/09b6a479-be02-42c5-bddb-a28359aa0fb7)
```bash
docker images
```
![image](https://github.com/user-attachments/assets/cc34bf13-4a52-4f08-8984-572c134f175b)
# Creating the Pozos Network

We have just built our image for the application's API. To ensure communication between the two microservices, we will create a network in which both applications will run. This will facilitate name resolution through DNS functions.

You should know that there are 4 types of networks on Docker, as you have seen in class.
```bash
sudo docker network create pozos_network --driver=bridge
sudo docker network ls
```
creating the api-pozos container
```bash
cd ..
sudo docker run --rm -d -p 5000:5000 --name api_pozos --network pozos_network -v ./simple_api/:/data/ api-pozos:1
```

***The --rm option tells Docker to automatically remove the container when it stops.***

***The -d option means "detached" (detached mode). This allows launching the container in the background***

We mount the local directory `./simple_api/` into the internal directory `/data/` of the container so that the API can use the `student_age.json` list.

we have therefore mounted a bind mount type volume
```bash
docker ps -a

```
![image](https://github.com/user-attachments/assets/135aa1be-b5ba-4bf4-be94-e3dc9ada2c89)

# Creating Webapp

The application's front-end is made in PHP. To communicate with the back-end you just deployed, you need to modify the web application configuration to give it the API host. This is what you are going to do.

Thanks to the DNS functions of our bridge-type network, we can easily use the API container name with the port we saw just before to adapt our website:

```bash
sed -i 's\<api_ip_or_name:port>\api_pozos:5000\g' ./website/index.php
```
launching 
```bash
sudo docker run --rm -d --name webapp_pozos -p 80:80 --network pozos_network -v ./website/:/var/www/html -e USERNAME=toto -e PASSWORD=python php:apache
```
```bash
sudo docker ps
```
![image](https://github.com/user-attachments/assets/769341b2-4858-4ff1-a295-ae4cdac92897)

# Testing Front-end and Back-end

We can therefore test to see if the front-end actually communicates with the back-end. To do this, we will execute the following command, which will ask the front container to make a request to the back-end API and return the result. The objective is to test if the API works and if the front-end can get the list of students from it.

```bash
sudo docker exec webapp_pozos curl -u toto:python -X GET http://api_pozos:5000/pozos/api/v1.0/get_student_ages
```
![image](https://github.com/user-attachments/assets/13a12c59-2b51-471a-b566-3b41fe192007)
![image](https://github.com/user-attachments/assets/39d760b2-8306-4c3b-8006-6ecd47e5aab7)

Thanks to the `--rm` argument we used when starting our containers, they will be removed when they stop. Remove the previously created network:

```bash
sudo docker stop api_pozos
sudo docker stop webapp_pozos
sudo docker network rm pozos_network
sudo docker network ls
sudo docker ps
```
# Deployment as Code

Since the tests have been passed, we can now put the `docker run` parameters we just saw in an infrastructure as code format, in a `docker-compose.yml` file. This will allow us to have a deliverable that we can send to the client.
see the ***docker-compose.yml*** file

***now to launch the application just sudo docker-compose up -d***
```bash
sudo docker-compose up -d
```
# Testing Front-end and Back-end
```bash
sudo docker exec webapp_student_list curl -u toto:python -X GET http://api_pozos:5000/pozos/api/v1.0/get_student_ages
```
![image](https://github.com/user-attachments/assets/13a12c59-2b51-471a-b566-3b41fe192007)
![image](https://github.com/user-attachments/assets/39d760b2-8306-4c3b-8006-6ecd47e5aab7)
We therefore have our application that continues to work, with the advantage that we can now share the code with the client.

# Creating the Private Registry

Creating the private registry that will host the company's images.

See `docker-compose-registry.yml`.
```bash
sudo docker-compose -f docker-compose-registry.yml up -d
```
![image](https://github.com/user-attachments/assets/569d0e44-c456-47a6-976b-828833d82cc0)

![image](https://github.com/user-attachments/assets/501c3353-899e-4027-850e-078eac481720)

# Pushing to the Private Registry
```bash
sudo docker login localhost:5000
sudo docker image tag api-pozos:1 localhost:5000/pozos/api-pozos:1
sudo docker images
sudo docker image push localhost:5000/pozos/api-pozos:1
```
# Private Registry Verification
![image](https://github.com/user-attachments/assets/7298ec67-efc9-4e21-91d2-daa9fabba3c0)

# Starting the Company's ERP
```bash
cd odoo
docker-compose up -d
```
## Application Availability Verification
![image](https://github.com/user-attachments/assets/f610ed9e-7821-42cd-9ac7-138c5764b700)

# Pushing the odoo image to the Company's Private Registry
```bash
sudo docker image tag odoo:10.0 localhost:5000/odoo:10.0
sudo docker images
sudo docker image push localhost:5000/odoo:10.0
```
![image](https://github.com/user-attachments/assets/44ce035a-f2f4-4546-8a5b-f77b997410b1)
