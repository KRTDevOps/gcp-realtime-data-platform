WITH source AS (

    SELECT
        user_id,
        event,
        timestamp,
        processed_at,
        event_type
    FROM `{{ var("source_project", "your-project-id") }}.{{ var("source_dataset", "realtime_dataset") }}.events`

),

cleaned AS (

    SELECT
        CAST(user_id AS INT64) AS user_id,
        TRIM(event) AS event,
        TIMESTAMP(timestamp) AS event_timestamp,
        TIMESTAMP(processed_at) AS processed_at,
        LOWER(event_type) AS event_type
    FROM source
    WHERE user_id IS NOT NULL

)

SELECT * FROM cleaned