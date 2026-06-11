with orders as (
    select order_id from {{ ref('stg_orders') }}
),

attribution as (
    select order_id from {{ ref('int_order_session_attribution') }}
)

select
    coalesce(orders.order_id, attribution.order_id) as order_id
from orders
full outer join attribution
    on orders.order_id = attribution.order_id
where orders.order_id is null
    or attribution.order_id is null
