# TUTORIAL

# Overview
This tutorial assumes you have some experience with tools such as Python, Bash scripts, Docker, and Terraform. 
You can run the pipeline locally or jump right to the cloud.

# Prerequisites
- A Google Cloud Account.
- A Google Service Account with rights to BigQuery, Cloud Storage, and Compute Engine.
- Install Terraform on your machine.
- Google Cloud CLI

# Local Setup
If you plan on running the pipeline locally you will need to install docker, and docker compose, on your 
host machine.

1. Clone the repo and cd into the directory
```
git clone https://github.com/KenImade/real_estate_dashboard.git real_estate_dashboard

cd real_estate_dashboard
```

2. If running on Linux you will need to change directory permissions for the dags, data, scripts, and logs folders
to allow airflow access to these folders.
```
chown -R 777 dags, data, logs, scripts

chmod -R 777 dags data logs scripts
```

3. Create a **.env** file and set the following
```
echo ENVIRONMENT=test>>.env
echo AIRFLOW_WEBSERVER_SECRET_KEY=my_secret_key>>.env
echo AIRFLOW_CONN_MY_GCP_CONNECTION='google-cloud-platform://?extra__google_cloud_platform__key_path=/opt/airflow/secrets/key.json'>>.env
echo GOOGLE_APPLICATION_CREDENTIALS_LOCAL=./keys/my-creds.json>>.env
```

4. Copy the service account json key into the keys directory and name the file **my-creds.json**

5. Change directory to terraform
```
cd terraform
```

6. Delete the files **main.tf** and **variables.tf**

7. Rename the files **main-for-local-setup.tf** to **main.tf**, and **variables-for-local-setup.tf** to **variables.tf**

8. Replace the Google Id in the variables.tf file with your google cloud project ID.

9. Replace the Storage bucket name with a unique name also.

10. Initialise and setup cloud infrastructure
```
terraform init
terraform plan
terraform apply
```

11. Leave the terraform directory and change directory into the dags folder and open the file **real_estate_dag.py** in your code editor
 and replace the variables at the top of the file with the names used in the terraform variables.tf file.
```
cd ..
cd dags
```
12. Change directory into **dbt_real_estate** and open the profiles.yml file. You will need to replace the project value under test with your Google Cloud Project ID.

13. If you have dbt installed locally you can ensure the connection is valid by running dbt debug however you will need to export an environment variable ENVIRONMENT
```
export ENVIRONMENT=test
dbt debug
```

14. Go up a level into the project directory
```
cd ..
```

15. Run the below command to bring up the application
```
docker compose up --build -d
```

16. Go to localhost:8080 to access the airflow UI

17. Input **admin** for the username and password

18. Run the dag


# Cloud Setup

1. Clone the repo and cd into the directory
```
git clone https://github.com/KenImade/real_estate_dashboard.git real_estate_dashboard

cd real_estate_dashboard
```

2. Place your service account json file in the keys folder

3. Change directory into the terraform folder
```
cd terraform
```
4. Delete the files **main-for-local-setup.tf** and **variables-for-local-setup.tf**

5. Replace the Google Project ID and Storage Bucket names in the variables.tf file

6. You will need to create another service account with permissions for Cloud Storage and BigQuery. Take note of the email address
and replace the variable **vm_service_account_email** in your variables.tf file.

7. Initialise and setup cloud infrastructure
```
terraform init
terraform plan
terraform apply
```
8. Leave the terraform directory and change directory into the dags folder and open the file **real_estate_dag.py** in your code editor
 and replace the variables at the top of the file with the names used in the terraform variables.tf file.
```
cd ..
cd dags
```
9. Log into your Google Cloud Console and Locate your VM instance under Compute Engine

10. Login into the VM and verify that the docker container is up and running. It might take a few minutes for the VM to spin up the container.
```
sudo docker ps
```
11. You will need to ssh into the VM and forward the port to access the Airflow UI.
```
gcloud compute ssh [INSTANCE_NAME] --zone [ZONE] -- -L 8080:localhost:8080
```
12. Input **admin** for the username and password

13. Run the dag