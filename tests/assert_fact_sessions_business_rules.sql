select *
from {{ ref('fact_sessions') }}
where session_end_at < session_start_at
    or session_duration_minutes < 0
    or event_count < 1
    or page_views_count < 0
    or product_views_count < 0
    or add_to_cart_count < 0
    or checkout_count < 0
    or purchase_count < 0
    or (is_converted_session and purchase_count < 1)
    or (not is_converted_session and purchase_count != 0)
    or (is_converted_session and first_order_id is null)
    or (not is_converted_session and first_order_id is not null)
