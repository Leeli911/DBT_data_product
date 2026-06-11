with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select * from {{ ref('int_order_items_enriched') }}
),

order_session_attribution as (
    select * from {{ ref('int_order_session_attribution') }}
),

order_item_summary as (
    select
        order_id,
        count(*) as order_line_count,
        sum(quantity) as total_quantity,
        sum(gross_item_amount) as gross_item_amount,
        sum(item_discount_amount) as item_discount_amount,
        sum(net_item_amount) as net_item_amount
    from order_items
    group by 1
)

select
    orders.order_id,
    orders.user_id,
    orders.order_timestamp,
    orders.order_date,
    orders.order_status,
    orders.traffic_source,
    order_session_attribution.attributed_traffic_source,
    order_session_attribution.converting_session_id,
    order_session_attribution.attribution_method,
    order_session_attribution.attribution_status,
    coalesce(order_item_summary.order_line_count, 0) as order_line_count,
    coalesce(order_item_summary.total_quantity, 0) as total_quantity,
    cast(coalesce(order_item_summary.gross_item_amount, 0) as decimal(18, 2)) as gross_item_amount,
    cast(coalesce(order_item_summary.item_discount_amount, 0) as decimal(18, 2)) as item_discount_amount,
    cast(coalesce(order_item_summary.net_item_amount, 0) as decimal(18, 2)) as net_item_amount,
    orders.subtotal_amount,
    orders.tax_amount,
    orders.shipping_amount,
    orders.discount_amount,
    orders.total_revenue,
    cast(
        case when orders.order_status != 'cancelled' then orders.total_revenue else 0 end
        as decimal(18, 2)
    ) as gmv_amount,
    cast(
        case when orders.order_status = 'returned' then orders.total_revenue else 0 end
        as decimal(18, 2)
    ) as returned_amount,
    orders.has_missing_revenue,
    orders.order_status = 'cancelled' as is_cancelled_order,
    orders.order_status = 'returned' as is_returned_order
from orders
left join order_item_summary
    on orders.order_id = order_item_summary.order_id
left join order_session_attribution
    on orders.order_id = order_session_attribution.order_id
