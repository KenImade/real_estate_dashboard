#!/bin/bash
# Script Name: download_data.sh
#
# Author: Kenneth Imade
# Date: 18/04/2024
# Modified by: Kenneth Imade
# Last Modified: 30/04/2024
#
#
#
# Description:
#   This script downloads data on Price Paid for real estate in 
#   England and Wales from the UK Governments Open Data Portal.
#  
# 
# Usage:
#   ./download_data.sh
# 
# Arguments:
#   None
# 
# Outputs:
#   Downloads csv files into the data/raw directory.
#   Prints the name of the file being downloaded.
# 
# Dependencies:
#   Requires wget to be installed in source system.



# Base directory for the script and data
BASE_DIR="/opt/airflow/"
DATA_DIR="${BASE_DIR}data/raw"

# Ensure the data directory exists
if [ ! -d "${DATA_DIR}" ]; then
    echo "Creating data directory at ${DATA_DIR}"
    mkdir -p "${DATA_DIR}"
fi

cd $BASE_DIR


for YEAR in {1995..2023}; do
    echo "Started Download Script execution for year ${YEAR}"
    echo "Current working directory: $(pwd)"

    URL="http://prod.publicdata.landregistry.gov.uk.s3-website-eu-west-1.amazonaws.com/pp-${YEAR}.csv"
    LOCAL_FILE="real_estate_data_${YEAR}.csv"
    LOCAL_PATH="${DATA_DIR}/${LOCAL_FILE}"
    
    # Check if files already exists if they do skip download
    if  [ ! -f "$LOCAL_PATH" ]; then
        echo "Downloading ${URL} to ${LOCAL_PATH}"
        if wget "${URL}" -O "${LOCAL_PATH}"; then
            echo "Download successful for ${YEAR}"
        else
            echo "Download failed for ${YEAR}, URL: ${URL}"
        fi
    fi
done

# Download latest data
LATEST_FILE_URL="http://prod.publicdata.landregistry.gov.uk.s3-website-eu-west-1.amazonaws.com/pp-monthly-update-new-version.csv"
LATEST_FILE="${DATA_DIR}/pp-monthly-update-new-version.csv"
echo "Downloading latest data file to ${LATEST_FILE}"
if wget "${LATEST_FILE_URL}" -O "${LATEST_FILE}"; then
    echo "Download of latest data successful"
else
    echo "Download of latest data failed"
fi