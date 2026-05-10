{{
    config(
        materialized         = 'incremental',
        incremental_strategy = 'insert_overwrite',
        engine               = 'OLAP',
        distributed_by       = ['BRANCH']
    )
}}

WITH source AS (

    SELECT
        BRANCH,
        POS_ID,
        SALE_DATE,
        PAYMENT,
        QUANTITY,
        STR_TO_DATE(DATE_UPDATED, '%Y%m%d')     AS DATE_UPDATED,
        TIME_UPDATED,
        USER_UPDATED,
        TS

    FROM staging_db.ELECTRICITY

    WHERE TS IS NOT NULL

    {% if is_incremental() %}
        AND TS >= NOW() - INTERVAL {{ var('loopback', 24) }} HOUR
    {% endif %}

)

SELECT * FROM source