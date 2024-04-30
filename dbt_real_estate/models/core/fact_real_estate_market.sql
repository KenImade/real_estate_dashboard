{{
    config(
        materialized='table'
    )
}}

WITH real_estate_data AS (
    SELECT 
        transaction_id,
        price,
        date_of_transfer,
        property_type_description,
        property_age_description,
        postcode,
        tenure_type,
        postcode_id
    FROM {{ref('stg_real_estate_model')}}
),

location_data AS (
    SELECT
        *
    FROM {{ref('dim_location_info')}}
)

SELECT
    transaction_id,
    price,
    date_of_transfer,
    property_type_description,
    property_age_description,
    tenure_type,
    postcode,
    eastings,
    northings,
    latitude,
    longitude,
    town,
    region
FROM real_estate_data
LEFT JOIN location_data
ON real_estate_data.postcode_id = location_data.postcode_id
