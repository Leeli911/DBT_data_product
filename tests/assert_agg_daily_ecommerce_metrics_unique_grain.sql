select
    metric_date,
    traffic_source,
    count(*) as row_count
from {{ ref('agg_daily_ecommerce_metrics') }}
group by 1, 2
having count(*) > 1
