{{
    config(
        materialized         = 'incremental',
        incremental_strategy = 'insert_overwrite',
        engine               = 'OLAP',
        distributed_by       = ['BILL_SERVICE_PROVIDER']
    )
}}

WITH source AS (

    SELECT
        BILL_SERVICE_PROVIDER,
        DESCRIPTION,
        ACCOUNT_KEY,
        STR_TO_DATE(DATE_UPDATED, '%Y%m%d')     AS DATE_UPDATED,
        DECIMAL_UPDATED,
        TIME_UPDATED,
        USER_UPDATED,
        TS

    FROM staging_db.BILL_SERVICE_PROVIDER

    WHERE TS IS NOT NULL

    {% if is_incremental() %}
        AND TS >= NOW() - INTERVAL {{ var('loopback', 24) }} HOUR
    {% endif %}

)

SELECT * FROM source