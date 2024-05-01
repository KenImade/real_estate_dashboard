FROM apache/airflow:2.9.0-python3.9

USER root

# Ensure packages are updated and install wget
RUN apt-get update && apt-get install -y wget

USER airflow

# requriements
COPY requirements.txt /usr/local/airflow/requirements.txt

# Install Python dependencies from requirements.txt
RUN pip install --upgrade pip && \
    pip install -r /usr/local/airflow/requirements.txt

# Set the working directory to the dbt project folder
WORKDIR /usr/local/airflow/dbt

USER root

# Set dbt profile directory in environment variable
ENV DBT_PROFILES_DIR=/usr/local/airflow/dbt

# Change the owner of the dbt directory and its contents to the airflow user
RUN chown -R 777 /usr/local/airflow/dbt

# Ensure the airflow user has read, write, and execute permissions
RUN chmod -R 777 /usr/local/airflow/dbt

# Copy Essential files
COPY ./dbt_real_estate /usr/local/airflow/dbt

# Change working directory back to airflow home
WORKDIR /usr/local/airflow

ENV ENVIRONMENT=${ENVIRONMENT}

USER airflow