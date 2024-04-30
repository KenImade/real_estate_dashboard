#!/bin/bash

# Environment variable
export ENVIRONMENT=prod
export GOOGLE_APPLICATION_CREDENTIALS_LOCAL=

# Update the package listing
sudo apt-get update

# Install necessary packages for Docker
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Set up the stable Docker repository
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update the package listing again
sudo apt-get update

# Install Docker CE
sudo apt-get install -y docker-ce

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add the current user to the Docker group
sudo usermod -aG docker $USER

# Make directory for application
mkdir -p /usr/local/real_estate_dashboard

# Clone repository
git clone https://github.com/KenImade/real_estate_dashboard /usr/local/real_estate_dashboard
cd /usr/local/real_estate_dashboard

# Run Docker Compose
docker-compose --env-file .env.production up -d