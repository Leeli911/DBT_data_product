select
    traffic_source,
    sum(gmv_amount) as gmv,
    sum(valid_order_count) as valid_orders,
    sum(converted_sessions) as converted_sessions,
    sum(total_sessions) as sessions,
    round(sum(converted_sessions) * 1.0 / nullif(sum(total_sessions), 0), 4) as conversion_rate,
    round(sum(gmv_amount) / nullif(sum(valid_order_count), 0), 2) as average_order_value
from {{ ref('agg_daily_ecommerce_metrics') }}
group by 1
order by gmv desc
