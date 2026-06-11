with aggregate_totals as (
    select
        sum(total_sessions) as total_sessions,
        sum(converted_sessions) as converted_sessions,
        sum(valid_order_count) as valid_order_count,
        sum(cancelled_order_count) as cancelled_order_count,
        sum(gmv_amount) as gmv_amount,
        sum(returned_amount) as returned_amount,
        sum(gross_item_amount) as gross_item_amount,
        sum(net_item_amount) as net_item_amount,
        sum(tax_amount) as tax_amount,
        sum(shipping_amount) as shipping_amount,
        sum(discount_amount) as discount_amount
    from {{ ref('agg_daily_ecommerce_metrics') }}
),

fact_totals as (
    select
        (select count(*) from {{ ref('fact_sessions') }}) as total_sessions,
        (select count(*) from {{ ref('fact_sessions') }} where is_converted_session) as converted_sessions,
        (select count(*) from {{ ref('fact_orders') }} where order_status != 'cancelled') as valid_order_count,
        (select count(*) from {{ ref('fact_orders') }} where order_status = 'cancelled') as cancelled_order_count,
        (select sum(gmv_amount) from {{ ref('fact_orders') }}) as gmv_amount,
        (select sum(returned_amount) from {{ ref('fact_orders') }}) as returned_amount,
        (select sum(gross_item_amount) from {{ ref('fact_orders') }} where order_status != 'cancelled') as gross_item_amount,
        (select sum(net_item_amount) from {{ ref('fact_orders') }} where order_status != 'cancelled') as net_item_amount,
        (select sum(tax_amount) from {{ ref('fact_orders') }} where order_status != 'cancelled') as tax_amount,
        (select sum(shipping_amount) from {{ ref('fact_orders') }} where order_status != 'cancelled') as shipping_amount,
        (select sum(discount_amount) from {{ ref('fact_orders') }} where order_status != 'cancelled') as discount_amount
)

select *
from aggregate_totals
cross join fact_totals
where aggregate_totals.total_sessions != fact_totals.total_sessions
    or aggregate_totals.converted_sessions != fact_totals.converted_sessions
    or aggregate_totals.valid_order_count != fact_totals.valid_order_count
    or aggregate_totals.cancelled_order_count != fact_totals.cancelled_order_count
    or abs(aggregate_totals.gmv_amount - fact_totals.gmv_amount) > 0.01
    or abs(aggregate_totals.returned_amount - fact_totals.returned_amount) > 0.01
    or abs(aggregate_totals.gross_item_amount - fact_totals.gross_item_amount) > 0.01
    or abs(aggregate_totals.net_item_amount - fact_totals.net_item_amount) > 0.01
    or abs(aggregate_totals.tax_amount - fact_totals.tax_amount) > 0.01
    or abs(aggregate_totals.shipping_amount - fact_totals.shipping_amount) > 0.01
    or abs(aggregate_totals.discount_amount - fact_totals.discount_amount) > 0.01
