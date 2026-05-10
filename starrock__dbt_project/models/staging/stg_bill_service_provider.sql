{{
    config(
        materialized         = 'incremental',
        unique_key           = 'BILL_SERVICE_PROVIDER',
        incremental_strategy = 'merge',
        engine               = 'OLAP',
        primary_key          = ['BILL_SERVICE_PROVIDER'],
        distributed_by       = 'BILL_SERVICE_PROVIDER'
    )
}}

WITH source AS (

    SELECT
        BILL_SERVICE_PROVIDER,
        DESCRIPTION,
        ACCOUNT_KEY,

        -- CHAR(8) → DATE
        STR_TO_DATE(DATE_UPDATED, '%Y%m%d')     AS DATE_UPDATED,

        DECIMAL_UPDATED,

        -- CHAR(10) → TIME
        CAST(TIME_UPDATED AS TIME)               AS TIME_UPDATED,

        USER_UPDATED,
        TS

    FROM {{ source('staging_db', 'BILL_SERVICE_PROVIDER') }}

    WHERE TS IS NOT NULL

    {% if is_incremental() %}
        AND TS >= NOW() - INTERVAL {{ var('loopback', 24) }} HOUR
    {% endif %}

)

SELECT * FROM source