with orders as (
    select * from {{ ref('stg_orders') }}
),

events as (
    select * from {{ ref('stg_events') }}
),

sessions as (
    select * from {{ ref('int_user_sessions') }}
),

purchase_event_candidates as (
    select
        orders.order_id,
        orders.user_id,
        sessions.session_id as converting_session_id,
        sessions.session_start_at,
        sessions.session_end_at,
        sessions.traffic_source as session_traffic_source,
        orders.traffic_source as order_traffic_source,
        sessions.traffic_source as attributed_traffic_source,
        'purchase_event_match' as attribution_method,
        'attributed' as attribution_status
    from orders
    inner join events
        on orders.order_id = events.order_id
        and orders.user_id = events.user_id
        and events.event_name = 'purchase'
    inner join sessions
        on events.user_id = sessions.user_id
        and events.event_timestamp between sessions.session_start_at and sessions.session_end_at
),

timestamp_window_candidates as (
    select
        orders.order_id,
        orders.user_id,
        sessions.session_id as converting_session_id,
        sessions.session_start_at,
        sessions.session_end_at,
        sessions.traffic_source as session_traffic_source,
        orders.traffic_source as order_traffic_source,
        sessions.traffic_source as attributed_traffic_source,
        'timestamp_window_match' as attribution_method,
        'attributed' as attribution_status
    from orders
    inner join sessions
        on orders.user_id = sessions.user_id
        and orders.order_timestamp between sessions.session_start_at and sessions.session_end_at
),

fallback_candidates as (
    select
        order_id,
        user_id,
        cast(null as varchar) as converting_session_id,
        cast(null as timestamp) as session_start_at,
        cast(null as timestamp) as session_end_at,
        cast(null as varchar) as session_traffic_source,
        traffic_source as order_traffic_source,
        traffic_source as attributed_traffic_source,
        'order_source_fallback' as attribution_method,
        'fallback' as attribution_status
    from orders
),

candidate_union as (
    select * from purchase_event_candidates
    union all
    select * from timestamp_window_candidates
    union all
    select * from fallback_candidates
),

ranked as (
    select
        *,
        row_number() over (
            partition by order_id
            order by
                case
                    when attribution_method = 'purchase_event_match' then 1
                    when attribution_method = 'timestamp_window_match' then 2
                    else 3
                end,
                coalesce(session_end_at, timestamp '1900-01-01 00:00:00') desc,
                coalesce(session_start_at, timestamp '1900-01-01 00:00:00') desc,
                converting_session_id
        ) as attribution_rank
    from candidate_union
)

select
    order_id,
    user_id,
    converting_session_id,
    session_start_at,
    session_end_at,
    session_traffic_source,
    order_traffic_source,
    attributed_traffic_source,
    attribution_method,
    attribution_status
from ranked
where attribution_rank = 1
