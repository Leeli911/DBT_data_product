with order_items as (
    select * from {{ ref('stg_order_items') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

products as (
    select * from {{ ref('stg_products') }}
)

select
    order_items.order_item_id,
    order_items.order_id,
    orders.user_id,
    orders.order_timestamp,
    orders.order_date,
    orders.order_status,
    orders.traffic_source,
    order_items.product_id,
    products.product_name,
    products.product_category,
    products.product_subcategory,
    products.product_brand,
    order_items.quantity,
    order_items.unit_price,
    order_items.discount_amount as item_discount_amount,
    cast(order_items.quantity * order_items.unit_price as decimal(18, 2)) as gross_item_amount,
    cast(
        greatest(order_items.quantity * order_items.unit_price - order_items.discount_amount, 0)
        as decimal(18, 2)
    ) as net_item_amount
from order_items
left join orders
    on order_items.order_id = orders.order_id
left join products
    on order_items.product_id = products.product_id
