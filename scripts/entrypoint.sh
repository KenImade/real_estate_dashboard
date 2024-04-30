#!/bin/bash
# Script Name: entrypoint.sh
#
# Author: Kenneth Imade
# Date: 20/04/2024
# Modified by: Kenneth Imade
# Last Modified: 30/04/2024
#
#
#
# Description:
#   This script is the entrypoint for the Airflow environment.
#   It creates an admin user for the Airflow UI and sets up the
#   postgres db for Airflow.
#  
# 
# Usage:
#   ./entrypoint.sh
# 
# Arguments:
#   None
# 
# Outputs:
#   None.
#   
# 
# Dependencies:
#   None.

set -e

if [ ! -f "/opt/airflow/airflow.db" ]; then
  airflow db init && \
  airflow users create \
    --username admin \
    --firstname admin \
    --lastname admin \
    --role Admin \
    --email admin@example.com \
    --password admin
fi

$(command -v airflow) db migrate

exec airflow webserver