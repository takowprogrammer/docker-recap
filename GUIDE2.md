# Comprehensive Guide to Running and Dockerizing the Application

This guide provides a step-by-step walkthrough for running the application, both with and without Docker, for the basic and advanced versions included in this repository.

## Part 1: Running the Basic Application Without Docker

This section explains how to run the `simple_api` and `website` components of the basic version on your local machine without using Docker.

### 1.1. Running the API (`simple_api`)

The API is a simple Flask application that provides student data from a JSON file.

**1.1.1. Prerequisites:**

*   Python 3.x installed on your system.
*   `pip` (Python package installer).

**1.1.2. Steps:**

1.  **Navigate to the API directory:**
    ```bash
    cd basic-version/simple_api
    ```

2. **Create and activate a virtual environment (Recommended):**
   This creates an isolated environment for the Python packages.

   *   **Create the virtual environment:**
       ```bash
       python -m venv venv
       ```
   *   **Activate the virtual environment:**
       The command to use depends on your operating system and shell. The script path is different because virtual environments are created differently on Windows vs. macOS/Linux.

       *   **On Windows:** The activation script is at `venv\Scripts\activate`.
           *   In **Command Prompt**:
               ```bash
               venv\Scripts\activate
               ```
           *   In **Git Bash** or **PowerShell**:
               ```bash
               source venv/Scripts/activate
               ```
       *   **On macOS or Linux:** The activation script is at `venv/bin/activate`.
           *   In a **bash** or **zsh** shell:
               ```bash
               source venv/bin/activate
               ```

3.  **Install the required Python packages:**
    ```bash
    pip install -r requirements.txt
    ```

4.  **Set the environment variable and run the API (in the same terminal):**
    The application needs to know where to find the `student_age.json` file. You must set this as an environment variable and run the application **in the same terminal session**.

    *   **For Windows (Command Prompt):**
        Open a Command Prompt, navigate to the `simple_api` directory, and run these commands:
        ```bash
        set student_age_file_path=c:\Users\Takow Carvin\Documents\GitHub\Point-Recap-Docker-Devops\basic-version\simple_api\student_age.json
        python student_age.py
        ```
    *   **For Windows (PowerShell):**
        Open a PowerShell terminal, navigate to the `simple_api` directory, and run these commands:
        ```powershell
        $env:student_age_file_path="c:\Users\Takow Carvin\Documents\GitHub\Point-Recap-Docker-Devops\basic-version\simple_api\student_age.json"
        python student_age.py
        ```
    *   **For macOS/Linux:**
        Open a terminal, navigate to the `simple_api` directory, and run these commands:
        ```bash
        export student_age_file_path=$(pwd)/student_age.json
        python student_age.py
        ```

5.  **Test the API:**
    The API should now be running at `http://127.0.0.1:5000`. You can test it using a tool like `curl` or a web browser. You'll need to provide the username `toto` and password `python` for authentication.

    ```bash
    curl -u toto:python http://127.0.0.1:5000/pozos/api/v1.0/get_student_ages
    ```

### 1.2. Running the Website (`website`)

The website is a simple PHP application that fetches and displays data from the API.

**1.2.1. Prerequisites:**

*   A local web server with PHP support (e.g., XAMPP, WAMP, MAMP, or a simple PHP development server).

    > **Note on Installing PHP:** If you don't have PHP, you can download it from the [official PHP website](https://www.php.net/downloads). After installation, you must add the PHP installation directory to your system's `PATH` environment variable. 

    > **Troubleshooting the `php` command:**
    > If the `php -v` command is not found after installation, follow these steps:
    > 1. **Restart Your Terminal:** The most common fix is to close and reopen your terminal (PowerShell, Git Bash, etc.).
    > 2. **Reboot Your Computer:** If restarting the terminal doesn't work, reboot your computer. Windows sometimes requires a restart to apply PATH changes system-wide.
    > 3. **Verify Your System PATH:**
    >    - Press the Windows key, type `env`, and select "Edit the system environment variables."
    >    - In the System Properties window, click the "Environment Variables..." button.
    >    - Under "System variables," find and select the `Path` variable, then click "Edit...".
    >    - In the list, make sure you see an entry pointing to your PHP installation folder (e.g., `C:\php`). If it's not there, add it.
    >    - **Important:** Ensure you are editing the **System variables**, not the User variables, for the change to be available to all terminals.
    > 4. **Check the PATH in Your Specific Terminal:**
    >    - If it works in Command Prompt but not Git Bash, open **Git Bash** and run `echo $PATH`. Check if your PHP folder is listed in the output. If not, it confirms a configuration issue specific to that shell, and a reboot (Step 2) is the most likely solution.

**1.2.2. Steps:**

1.  **Modify the API URL in `index.php`:**
    The `index.php` file is hardcoded to look for an API at `http://api_pozos:5000`. You need to change this to your local API address.

    *   Open `basic-version/website/index.php`.
    *   Find the line: `$url = 'http://api_pozos:5000/pozos/api/v1.0/get_student_ages';`
    *   Change it to: `$url = 'http://127.0.0.1:5000/pozos/api/v1.0/get_student_ages';`

2.  **Set credentials:**
    The PHP script uses the environment variables `USERNAME` and `PASSWORD` to authenticate with the API. For local testing, you can either set these in your web server's configuration or hardcode them in the script for simplicity.

    *   Open `basic-version/website/index.php`.
    *   Find these lines:
        ```php
        $username = getenv('USERNAME');
        $password = getenv('PASSWORD');
        ```
    *   Replace them with:
        ```php
        $username = 'john123';
        $password = 'python';
        ```

3.  **Start your local web server:**
    *   Place the `website` directory in your web server's document root (e.g., `htdocs` for XAMPP).
    *   Alternatively, you can use PHP's built-in development server. Navigate to the `website` directory and run:
        ```bash
        php -S localhost:8080
        ```

4.  **Access the website:**
    Open your web browser and go to `http://localhost/website/` (if using a server like XAMPP) or `http://localhost:8080` (if using the PHP development server). You should see the "Student Checking App" and a button to list the students.


## Part 2: Dockerizing the Basic Application

Now, let's dockerize the application. This involves creating Docker images for our API and website and then using Docker Compose to run them together.

### 2.1. Analyzing the Application Architecture

Before writing any Docker files, we need to understand the components of our application:

*   **`simple_api`**: A Python Flask backend service.
*   **`website`**: A PHP frontend service that communicates with the API.

This two-tier architecture means we will need two Docker services. They will need to communicate with each other, so we will also need a Docker network.

### 2.2. Writing the Dockerfiles

We need a `Dockerfile` for each service to define its image.

**2.2.1. `simple_api/Dockerfile`**

Here is the breakdown of the existing `simple_api/Dockerfile`:

```dockerfile
# Use a specific Python version for reproducibility
ARG VERSION="3.8-slim"
FROM python:$VERSION

# Add metadata to the image
LABEL maintainer="datascientest" email="contact@datascientest.fr"

# Install system dependencies required for Python packages
RUN apt update -y && apt install python3-dev libsasl2-dev libldap2-dev libssl-dev gcc -y

# Copy the application files into the image
COPY requirements.txt student_age.py /

# Install Python dependencies
RUN pip3 install -r /requirements.txt

# Create a volume to persist data
VOLUME /data

# Expose the port the application runs on
EXPOSE 5000

# Define the command to run the application
CMD [ "python3", "./student_age.py" ]
```

**2.2.2. Creating a `website/Dockerfile`**

The `website` directory doesn't have a `Dockerfile`. Let's create one. We'll use a standard PHP-Apache image and copy our website files into it.

1.  Create a new file named `Dockerfile` inside the `basic-version/website` directory.
2.  Add the following content:

    ```dockerfile
    # Use the official PHP image with Apache
    FROM php:7.4-apache

    # Copy the website files to the Apache document root
    COPY . /var/www/html/

    # Enable the PHP module for making HTTP requests
    RUN docker-php-ext-install pdo pdo_mysql
    ```

### 2.3. Writing the `docker-compose.yml` File

Docker Compose allows us to define and run multi-container applications. The `docker-compose.yml` file in the `basic-version` directory orchestrates our two services.

Here is a breakdown of the `docker-compose.yml` file:

```yaml
version: '3.3'
services:
  webapp.student_list:
    # We will build this image from the website/Dockerfile
    build: ./website
    image: webapp-pozos:1
    container_name: webapp_student_list
    depends_on:
      - pozos_api
    ports:
      - "80:80"
    environment:
      - USERNAME=toto
      - PASSWORD=python
    networks:
      - pozos_network

  pozos_api:
    # We will build this image from the simple_api/Dockerfile
    build: ./simple_api
    image: api-pozos:1
    container_name: api_pozos
    ports:
      - "5000:5000"
    volumes:
      - './simple_api/:/data/'
    networks:
      - pozos_network

networks:
  pozos_network:
    name: pozos_network
    driver: bridge
```

**Key Concepts:**

*   **`services`**: Defines the containers to be run (`webapp.student_list` and `pozos_api`).
*   **`build`**: Specifies the directory containing the `Dockerfile` for each service.
*   **`image`**: Names the image that will be built.
*   **`container_name`**: Assigns a specific name to the container.
*   **`depends_on`**: Ensures that the `pozos_api` service starts before the `webapp.student_list` service.
*   **`ports`**: Maps ports from the host to the container (e.g., `80:80` maps the host's port 80 to the container's port 80).
*   **`environment`**: Sets environment variables inside the container. This is how we pass the API credentials to the website.
*   **`volumes`**: Mounts the `simple_api` directory into the `/data` directory of the `pozos_api` container. This allows the API to access the `student_age.json` file.
*   **`networks`**: Creates a custom bridge network named `pozos_network`, allowing the containers to communicate with each other using their service names as hostnames (e.g., the website can reach the API at `http://pozos_api:5000`).


## Part 3: Running the Basic Dockerized Application

With the `Dockerfile`s and `docker-compose.yml` in place, we can now build and run the application using Docker Compose.

### 3.1. Steps

1.  **Navigate to the `basic-version` directory:**
    ```bash
    cd basic-version
    ```

2.  **Build and run the services:**
    This command will build the images for the `simple_api` and `website` services (if they don't already exist) and then start the containers.

    ```bash
    docker-compose up --build
    ```

    *   The `--build` flag forces Docker to rebuild the images, which is useful if you've made changes to the `Dockerfile`s or the application code.
    *   You can add the `-d` flag to run the containers in detached mode (in the background).

3.  **Access the application:**
    *   **Website**: Open your web browser and go to `http://localhost`. You should see the "Student Checking App".
    *   **API**: You can test the API directly at `http://localhost:5000/pozos/api/v1.0/get_student_ages` (e.g., with `curl -u toto:python http://localhost:5000/pozos/api/v1.0/get_student_ages`).

4.  **Stopping the application:**
    To stop the containers, press `Ctrl+C` in the terminal where `docker-compose` is running. If you are running in detached mode, use the following command:

    ```bash
    docker-compose down
    ```


## Part 4: Running the Advanced Dockerized Application

The `advanced-version` of the application introduces a more robust and production-ready architecture. It includes separate development and production configurations, uses a PostgreSQL database, and adds an Nginx reverse proxy.

### 4.1. Architecture Overview

The advanced application consists of the following services:

*   **`database`**: A PostgreSQL database to store student data.
*   **`api`**: The Python Flask API, now adapted to connect to the PostgreSQL database.
*   **`webapp`**: The PHP website, which remains largely the same but now communicates with the new API.
*   **`nginx`**: An Nginx reverse proxy that manages incoming traffic and directs it to the appropriate service (either the API or the webapp).
*   **`registry`**: A private Docker registry for storing the application's Docker images.

### 4.2. Environment and Secret Management

The advanced version uses a more sophisticated approach to configuration, separating environment variables and secrets.

**4.2.1. Environment Variables**

Environment-specific (non-sensitive) configurations are stored in `.env` files:

*   `configs/environments/env.dev`: For the development environment.
*   `configs/environments/env.prod`: For the production environment.

These files are loaded by Docker Compose when you run the application, setting variables like the database name, user, and application title.

**4.2.2. Docker Secrets**

For sensitive information like passwords, the production environment uses Docker Secrets. This is a more secure way to manage credentials than using environment variables.

**How to create and use secrets:**

1.  **Create the secret files:**
    The `docker-compose.prod.yml` file references several secrets (e.g., `postgres_password`, `api_username`, `api_password`). You need to create these files inside the `configs/secrets` directory.

    *   **For Windows (Command Prompt):**
        ```bash
        echo your_secure_password > configs\secrets\postgres_password
        echo your_api_username > configs\secrets\api_username
        echo your_api_password > configs\secrets\api_password
        ```
    *   **For Windows (PowerShell):**
        ```bash
        "your_secure_password" | Out-File -FilePath configs\secrets\postgres_password -Encoding ascii
        "your_api_username" | Out-File -FilePath configs\secrets\api_username -Encoding ascii
        "your_api_password" | Out-File -FilePath configs\secrets\api_password -Encoding ascii
        ```
    *   **For macOS/Linux:**
        ```bash
        echo "your_secure_password" > configs/secrets/postgres_password
        echo "your_api_username" > configs/secrets/api_username
        echo "your_api_password" > configs/secrets/api_password
        ```

2.  **How secrets are used in `docker-compose.prod.yml`:**
    *   The `secrets` block at the top level defines the secrets that will be created.
    *   The `secrets` block within a service definition makes the secret available to that service.
    *   The application code is then written to read the secret from the path `/run/secrets/<secret_name>`.

### 4.3. Monitoring

The `monitoring` directory is present in the `advanced-version`, suggesting that monitoring services (like Prometheus and Grafana) are intended to be part of the stack. However, the directory is currently empty. To implement monitoring, you would typically:

1.  Add Prometheus and Grafana services to your `docker-compose.yml`.
2.  Configure Prometheus to scrape metrics from your application's API.
3.  Create dashboards in Grafana to visualize the metrics.

As this is not yet implemented, it remains a potential extension of the project.




*   `configs/environments/env.dev`: Contains variables for the development environment.
*   `configs/environments/env.prod`: Contains variables for the production environment.

Docker Compose automatically loads these variables based on the files you specify in the `docker-compose` command.

### 4.3. Running the Development Environment

The development environment is configured for ease of use and debugging.

**4.3.1. Steps:**

1.  **Navigate to the `advanced-version` directory:**
    ```bash
    cd advanced-version
    ```

2.  **Run the development stack:**
    This command uses the base `docker-compose.yml` file and loads the development environment variables.

    ```bash
    docker-compose --env-file ./configs/environments/env.dev up --build
    ```

3.  **Access the application:**
    *   **Website**: Open your web browser and go to `http://localhost:8080` (the port is defined by `NGINX_PORT` in `env.dev`).

### 4.4. Running the Production Environment

The production environment is optimized for security and performance. It uses Docker Secrets to manage sensitive data like passwords.

**4.4.1. Prerequisites:**

*   You need to create the secret files that are defined in the `docker-compose.prod.yml` file. These are located in the `configs/secrets` directory. For example, you would create a file named `postgres_password` in the `configs/secrets` directory and put the database password in it.

**4.4.2. Steps:**

1.  **Navigate to the `advanced-version` directory:**
    ```bash
    cd advanced-version
    ```

2.  **Run the production stack:**
    This command merges the base `docker-compose.yml` with the `docker-compose.prod.yml` override file and loads the production environment variables.

    ```bash
    docker-compose -f docker-compose.yml -f docker-compose.prod.yml --env-file ./configs/environments/env.prod up --build
    ```

3.  **Access the application:**
    *   **Website**: Open your web browser and go to `http://localhost` (the port is mapped to 80 in the production configuration).

### 4.5. Stopping the Application

To stop either the development or production stack, use the `down` command with the same files you used to start it.

*   **Development:**
    ```bash
    docker-compose --env-file ./configs/environments/env.dev down
    ```
*   **Production:**
    ```bash
    docker-compose -f docker-compose.yml -f docker-compose.prod.yml down
    ```

## Part 5: Running Odoo

The `basic-version` also includes a configuration for running Odoo, a popular open-source ERP and CRM tool.

### 5.1. Architecture

The Odoo setup consists of two services:

*   **`web`**: The Odoo application itself.
*   **`db`**: A PostgreSQL database for Odoo to store its data.

### 5.2. Steps

1.  **Navigate to the `odoo` directory:**
    ```bash
    cd basic-version/odoo
    ```

2.  **Run the Odoo stack:**
    ```bash
    docker-compose up -d
    ```

3.  **Access Odoo:**
    Open your web browser and go to `http://localhost:8069`. You will be greeted with the Odoo setup screen to create a new database.

4.  **Stopping Odoo:**
    ```bash
    docker-compose down
    ```

## Part 6: Running the Docker Registry

A local Docker registry is included for storing and managing your Docker images.

### 6.1. Architecture

The registry setup includes:

*   **`pozos-registry`**: The Docker registry where images are stored.
*   **`frontend-reg`**: A web UI for browsing the images in the registry.

### 6.2. Steps

1.  **Navigate to the `basic-version` directory:**
    ```bash
    cd basic-version
    ```

2.  **Run the registry stack:**
    ```bash
    docker-compose -f docker-compose-registry.yml up -d
    ```

3.  **Access the registry UI:**
    Open your web browser and go to `http://localhost:8080` to see the web interface for your local registry.

4.  **Pushing an image to the registry:**
    To push an image, you need to tag it with the registry's address (`localhost:5000`) and then push it.

    ```bash
    # 1. Tag the image
    docker tag api-pozos:1 localhost:5000/api-pozos:1

    # 2. Push the image
    docker push localhost:5000/api-pozos:1
    ```

5.  **Stopping the registry:**
    ```bash
    docker-compose -f docker-compose-registry.yml down
    ```