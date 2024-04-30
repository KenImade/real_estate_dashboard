{{ config(materialized='table') }}

SELECT
    postcode AS postcode_id,
    eastings,
    northings,
    latitude,
    longitude,
    town,
    region
FROM {{ ref('postcodes_lookup') }}