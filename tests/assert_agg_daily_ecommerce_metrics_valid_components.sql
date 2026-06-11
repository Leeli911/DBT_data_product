select *
from {{ ref('agg_daily_ecommerce_metrics') }}
where converted_sessions > total_sessions
    or repeat_purchasing_users > purchasing_users
    or new_active_users + returning_active_users != active_users
    or total_sessions < 0
    or converted_sessions < 0
    or active_users < 0
    or valid_order_count < 0
    or cancelled_order_count < 0
    or purchasing_users < 0
    or repeat_purchasing_users < 0
    or gmv_amount < 0
    or returned_amount < 0
