{{
    config(
        materialized='view'
    )
}}

-- CTEs
WITH current_year_updates AS (
    -- All updates in the current year (2024)
    SELECT
        *
    FROM {{ source('staging', 'uk_real_estate_analytics') }}
    WHERE is_update = 'Y' AND cast(date_of_transfer as date) >= '2024-01-01'
),

old_data_updated AS (
    -- Old data that has been updated
    SELECT
        *
    FROM {{ source('staging', 'uk_real_estate_analytics') }}
    WHERE is_update = 'Y' AND cast(date_of_transfer as date) < '2024-01-01'
),

old_data_not_updated AS (
    -- Old data that has never been updated
    SELECT a.*
    FROM {{ source('staging', 'uk_real_estate_analytics') }} a
    LEFT JOIN old_data_updated b
        ON a.transaction_unique_identifier = b.transaction_unique_identifier
    WHERE a.is_update = 'N'
    AND b.transaction_unique_identifier IS NULL
),

full_data AS (
    SELECT *
    FROM current_year_updates
    UNION ALL
    SELECT *
    FROM old_data_updated
    UNION ALL
    SELECT *
    FROM old_data_not_updated
),

real_estate_data AS (
    SELECT *,
        row_number() over(partition by date_of_transfer) as rn
    FROM full_data
)


SELECT
    -- identifier
    {{dbt_utils.generate_surrogate_key(['transaction_unique_identifier'])}} as transaction_id,

    -- price
    cast(price as numeric) as price,

    -- Convert date coulumn
    cast(date_of_transfer as date) as date_of_transfer,

    postcode,
    {{get_property_type_description("property_type")}} as property_type_description,
    old_new as property_age,
    {{get_property_age_description("old_new")}} as property_age_description,
    {{get_tenure_type("duration")}} as tenure_type,
    postcode_outward_code AS postcode_id
FROM real_estate_data
