with products as (
    select * from {{ ref('stg_products') }}
),

order_items as (
    select * from {{ ref('int_order_items_enriched') }}
),

sales_summary as (
    select
        product_id,
        min(order_timestamp) as first_sold_at,
        max(order_timestamp) as last_sold_at,
        count(*) as lifetime_order_lines,
        sum(quantity) as lifetime_quantity_sold,
        sum(gross_item_amount) as lifetime_gross_item_amount,
        sum(net_item_amount) as lifetime_net_item_amount
    from order_items
    where order_status != 'cancelled'
    group by 1
)

select
    products.product_id,
    products.product_name,
    products.product_category,
    products.product_subcategory,
    products.product_brand,
    products.list_price,
    products.is_active,
    sales_summary.first_sold_at,
    sales_summary.last_sold_at,
    coalesce(sales_summary.lifetime_order_lines, 0) as lifetime_order_lines,
    coalesce(sales_summary.lifetime_quantity_sold, 0) as lifetime_quantity_sold,
    cast(coalesce(sales_summary.lifetime_gross_item_amount, 0) as decimal(18, 2)) as lifetime_gross_item_amount,
    cast(coalesce(sales_summary.lifetime_net_item_amount, 0) as decimal(18, 2)) as lifetime_net_item_amount
from products
left join sales_summary
    on products.product_id = sales_summary.product_id
