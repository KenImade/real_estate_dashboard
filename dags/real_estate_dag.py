from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.providers.google.cloud.transfers.local_to_gcs import LocalFilesystemToGCSOperator
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from airflow.operators.python import PythonOperator
from airflow.utils.dates import days_ago

from datetime import datetime, timedelta
import glob
import os

# Constants
GCS_BUCKET_NAME = 'uk-real-estate-analytics-bucket-personal-projects-420210'
GC_PROJECT_ID = 'personal-projects-420210'
BQ_DATASET_NAME = 'uk_real_estate_analytics_bq_dataset_personal_projects_420210'
GCS_CONN_ID = 'my_gcp_connection'
BQ_TABLE_NAME = 'uk_real_estate_analytics'


def upload_files():
    """
    Uploads all Parquet files from the specified local directory to GCS.
    
    Scans the /opt/airflow/data/clean directory for any .parquet files,
    then uploads each file to the GCS bucket defined in the environment.
    """
    files = glob.glob('/opt/airflow/data/clean/*.parquet')
    for file in files:
        LocalFilesystemToGCSOperator(
            task_id=f'upload_{os.path.basename(file).replace(".", "_")}',
            src=file,
            dst=f'real_estate_data/{os.path.basename(file)}',
            bucket=GCS_BUCKET_NAME,
            gcp_conn_id=GCS_CONN_ID
        ).execute({})


default_args = {
    'owner': 'kenneth',
    'start_date': days_ago(1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'real_estate_automation',
    default_args=default_args,
    description='A simple DAG to automate real estate data operations',
    schedule_interval='@monthly',
    catchup=False,
    tags=['real estate']
)

create_directories_task = BashOperator(
    task_id='create_data_directory',
    bash_command="mkdir -p /opt/airflow/data/raw /opt/airflow/data/clean && ls -l",
    dag=dag
)
create_directories_task.__doc__ = """
Creates necessary directories for storing raw and clean data.
This task ensures the base file structure is in place before data download begins.
"""

install_dbt_deps = BashOperator(
    task_id='install_dbt_deps',
    bash_command='cd /usr/local/airflow/dbt && dbt deps',
    dag=dag
)
install_dbt_deps.__doc__="""
Install the required dependencies to run dbt.
"""

download_data_task = BashOperator(
    task_id='download_data',
    bash_command='./scripts/download_data.sh',
    dag=dag
)
download_data_task.__doc__="""
Runs the bash script to download data from the UK Government Data Portal
"""

process_data_task = BashOperator(
    task_id='process_data',
    bash_command='python /opt/airflow/dags/scripts/clean_data.py /opt/airflow/data/raw /opt/airflow/data/clean',
    dag=dag
)
process_data_task.__doc__="""
Runs the Python script to process the data.
"""

upload_files_task = PythonOperator(
    task_id='upload_files_to_gcs',
    python_callable=upload_files,
    dag=dag
)
upload_files_task.__doc__="""
Uploads the processed files to a Google Storage Bucket.
"""

load_data_to_bq_task = GCSToBigQueryOperator(
    task_id='load_parquet_to_bq',
    bucket=GCS_BUCKET_NAME,
    source_objects=['real_estate_data/*.parquet'],
    destination_project_dataset_table=f'{GC_PROJECT_ID}:{BQ_DATASET_NAME}.{BQ_TABLE_NAME}',
    source_format='PARQUET',
    gcp_conn_id=GCS_CONN_ID,
    create_disposition='CREATE_IF_NEEDED',
    write_disposition='WRITE_APPEND',
    dag=dag
)
load_data_to_bq_task.__doc__="""
Loads the parquet files from the Google Storage Bucket to a BigQuery Table.
"""

load_dbt_seed = BashOperator(
    task_id='load_dbt_seed',
    bash_command='cd /usr/local/airflow/dbt && dbt seed --profile dbt_real_estate',
    dag=dag
)
load_dbt_seed.__doc__="""
Loads the seed for the dbt model into BigQuery.
"""

run_dbt_task = BashOperator(
    task_id='run_dbt',
    bash_command='cd /usr/local/airflow/dbt && dbt run --profile dbt_real_estate',
    dag=dag
)
run_dbt_task.__doc__="""
Runs the dbt models.
"""

[create_directories_task, install_dbt_deps] >> download_data_task >> process_data_task >> upload_files_task >> load_data_to_bq_task >> load_dbt_seed >> run_dbt_task