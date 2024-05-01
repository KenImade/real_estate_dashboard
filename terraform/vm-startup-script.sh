#!/bin/bash
# Script Name: vm-startup-script.sh
#
# Author: Kenneth Imade
# Date: 30/04/2024
# Modified by: Kenneth Imade
# Last Modified: 01/05/2024
#
#
#
# Description:
#   This script sets up the production environment to run the data pipeline.
#   It will be called by terraform during its apply process.
# 
# Usage:
#   ./vm-startup-script.sh
# 
# Arguments:
#   None
# 
# Outputs:
#   None
#
# 
# Dependencies:
#   None.
echo "Running script as $(whoami)"

echo "ENVIRONMENT=prod" | sudo tee -a /etc/environment

sudo apt-get update
sudo sudo apt-get install git

# Add Docker's official GPG key:
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

yes | sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Cloning the repository..."
cd $(whoami)
git clone https://github.com/KenImade/real_estate_dashboard.git real_estate_dashboard

echo "Changing to the directory..."
cd real_estate_dashboard

# Change group ownership
chown -R 777 dags data logs scripts
chmod -R 777 dags data logs scripts

# Create env file
echo "AIRFLOW_WEBSERVER_SECRET_KEY=KnsbA9ruUFuYMNoZfkuZXn6AxgBpokOFa-mUEdlw0Ec" >> .env
echo "ENVIRONMENT=prod">>.env

echo "Running Docker Compose..."

sudo docker compose \
    --env-file .env \
    -f docker-compose.yml \
    -f docker-compose.prod.yml up \
    --build -d


echo "Script execution complete."