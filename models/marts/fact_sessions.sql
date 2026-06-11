with sessions as (
    select * from {{ ref('int_user_sessions') }}
)

select
    session_id,
    user_id,
    session_start_at,
    cast(session_start_at as date) as session_date,
    session_end_at,
    session_duration_minutes,
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
    is_converted_session,
    first_order_id
from sessions
