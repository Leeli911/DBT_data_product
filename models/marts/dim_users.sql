with users as (
    select * from {{ ref('stg_users') }}
),

sessions as (
    select * from {{ ref('int_user_sessions') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

session_summary as (
    select
        user_id,
        min(session_start_at) as first_active_at,
        max(session_end_at) as last_active_at,
        count(*) as lifetime_sessions,
        sum(case when is_converted_session then 1 else 0 end) as lifetime_converted_sessions
    from sessions
    group by 1
),

order_summary as (
    select
        user_id,
        min(order_timestamp) as first_order_at,
        max(order_timestamp) as last_order_at,
        count(*) as lifetime_orders,
        sum(case when order_status != 'cancelled' then total_revenue else 0 end) as lifetime_gmv
    from orders
    group by 1
)

select
    users.user_id,
    users.user_created_at,
    users.country,
    users.acquisition_channel,
    users.lifecycle_stage,
    users.is_marketing_opted_in,
    session_summary.first_active_at,
    session_summary.last_active_at,
    coalesce(session_summary.lifetime_sessions, 0) as lifetime_sessions,
    coalesce(session_summary.lifetime_converted_sessions, 0) as lifetime_converted_sessions,
    order_summary.first_order_at,
    order_summary.last_order_at,
    coalesce(order_summary.lifetime_orders, 0) as lifetime_orders,
    cast(coalesce(order_summary.lifetime_gmv, 0) as decimal(18, 2)) as lifetime_gmv,
    coalesce(order_summary.lifetime_orders, 0) >= 2 as is_repeat_buyer
from users
left join session_summary
    on users.user_id = session_summary.user_id
left join order_summary
    on users.user_id = order_summary.user_id
