select *
from {{ ref('fact_orders') }}
where (
        order_status = 'cancelled'
        and (gmv_amount != 0 or not is_cancelled_order)
    )
    or (
        order_status != 'cancelled'
        and (gmv_amount != total_revenue or is_cancelled_order)
    )
    or (
        order_status = 'returned'
        and (returned_amount != total_revenue or not is_returned_order)
    )
    or (
        order_status != 'returned'
        and (returned_amount != 0 or is_returned_order)
    )
    or order_line_count < 1
    or total_quantity < order_line_count
    or gross_item_amount < net_item_amount
    or total_revenue < 0
    or gmv_amount < 0
    or returned_amount < 0
    or attributed_traffic_source is null
    or attribution_method not in ('purchase_event_match', 'timestamp_window_match', 'order_source_fallback')
    or attribution_status not in ('attributed', 'fallback')
    or (
        attribution_status = 'attributed'
        and converting_session_id is null
    )
    or (
        attribution_status = 'fallback'
        and converting_session_id is not null
    )
    or (
        attribution_method = 'order_source_fallback'
        and attribution_status != 'fallback'
    )
    or (
        attribution_method != 'order_source_fallback'
        and attribution_status != 'attributed'
    )
