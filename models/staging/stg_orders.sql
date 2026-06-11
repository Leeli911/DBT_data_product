with source as (
    select * from {{ ref('raw_orders') }}
),

typed as (
    select
        cast(order_id as varchar) as order_id,
        cast(user_id as varchar) as user_id,
        cast(order_timestamp as timestamp) as order_timestamp,
        cast(order_timestamp as date) as order_date,
        lower(cast(order_status as varchar)) as order_status,
        lower(cast(traffic_source as varchar)) as traffic_source,
        cast(coalesce(try_cast(subtotal_amount as decimal(18, 2)), 0) as decimal(18, 2)) as subtotal_amount,
        cast(coalesce(try_cast(tax_amount as decimal(18, 2)), 0) as decimal(18, 2)) as tax_amount,
        cast(coalesce(try_cast(shipping_amount as decimal(18, 2)), 0) as decimal(18, 2)) as shipping_amount,
        cast(coalesce(try_cast(discount_amount as decimal(18, 2)), 0) as decimal(18, 2)) as discount_amount,
        try_cast(total_revenue as decimal(18, 2)) is null as has_missing_revenue,
        cast(coalesce(try_cast(total_revenue as decimal(18, 2)), 0) as decimal(18, 2)) as total_revenue
    from source
)

select * from typed
