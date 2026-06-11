with events as (
    select * from {{ ref('stg_events') }}
),

ordered_events as (
    select
        *,
        lag(event_timestamp) over (
            partition by user_id
            order by event_timestamp, event_id
        ) as previous_event_timestamp
    from events
),

session_boundaries as (
    select
        *,
        case
            when previous_event_timestamp is null then 1
            when date_diff('minute', previous_event_timestamp, event_timestamp) > 30 then 1
            else 0
        end as is_new_session_boundary
    from ordered_events
),

sessionized as (
    select
        *,
        sum(is_new_session_boundary) over (
            partition by user_id
            order by event_timestamp, event_id
            rows between unbounded preceding and current row
        ) as user_session_number
    from session_boundaries
),

ranked as (
    select
        *,
        row_number() over (
            partition by user_id, user_session_number
            order by event_timestamp, event_id
        ) as session_event_sequence,
        row_number() over (
            partition by user_id, user_session_number
            order by event_timestamp desc, event_id desc
        ) as reverse_session_event_sequence
    from sessionized
),

aggregated as (
    select
        user_id || '-' || lpad(cast(user_session_number as varchar), 4, '0') as session_id,
        user_id,
        min(event_timestamp) as session_start_at,
        max(event_timestamp) as session_end_at,
        max(case when session_event_sequence = 1 then traffic_source end) as traffic_source,
        max(case when session_event_sequence = 1 then device_category end) as device_category,
        max(case when session_event_sequence = 1 then page_location end) as landing_page,
        max(case when reverse_session_event_sequence = 1 then page_location end) as exit_page,
        count(*) as event_count,
        sum(case when event_name = 'page_view' then 1 else 0 end) as page_views_count,
        sum(case when event_name = 'view_item' then 1 else 0 end) as product_views_count,
        sum(case when event_name = 'add_to_cart' then 1 else 0 end) as add_to_cart_count,
        sum(case when event_name = 'begin_checkout' then 1 else 0 end) as checkout_count,
        sum(case when event_name = 'purchase' then 1 else 0 end) as purchase_count,
        max(case when event_name = 'purchase' then order_id end) as first_order_id
    from ranked
    group by 1, 2
)

select
    session_id,
    user_id,
    session_start_at,
    session_end_at,
    cast(date_diff('minute', session_start_at, session_end_at) as integer) as session_duration_minutes,
    traffic_source,
    device_category,
    landing_page,
    exit_page,
    event_count,
    page_views_count,
    product_views_count,
    add_to_cart_count,
    checkout_count,
    purchase_count,
    purchase_count > 0 as is_converted_session,
    first_order_id
from aggregated
