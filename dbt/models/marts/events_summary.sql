SELECT
    event_type,
    COUNT(*) AS total_events,
    COUNT(DISTINCT user_id) AS unique_users
FROM {{ ref('stg_events') }}
GROUP BY event_type
ORDER BY total_events DESC