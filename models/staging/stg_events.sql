with source as (
    select * from {{ ref('raw_events') }}
),

typed as (
    select
        cast(event_id as varchar) as event_id,
        cast(event_timestamp as timestamp) as event_timestamp,
        cast(event_timestamp as date) as event_date,
        cast(user_id as varchar) as user_id,
        cast(anonymous_id as varchar) as anonymous_id,
        cast(session_id as varchar) as source_session_id,
        lower(cast(event_name as varchar)) as event_name,
        lower(cast(traffic_source as varchar)) as traffic_source,
        cast(page_location as varchar) as page_location,
        nullif(cast(product_id as varchar), '') as product_id,
        nullif(cast(order_id as varchar), '') as order_id,
        try_cast(revenue as decimal(18, 2)) as revenue,
        lower(cast(device_category as varchar)) as device_category
    from source
),

deduplicated as (
    select
        *,
        row_number() over (
            partition by event_id
            order by event_timestamp desc
        ) as event_deduplication_rank
    from typed
)

select
    event_id,
    event_timestamp,
    event_date,
    user_id,
    anonymous_id,
    source_session_id,
    event_name,
    traffic_source,
    page_location,
    product_id,
    order_id,
    revenue,
    device_category
from deduplicated
where event_deduplication_rank = 1
