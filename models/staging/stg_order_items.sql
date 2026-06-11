with source as (
    select * from {{ ref('raw_order_items') }}
),

renamed as (
    select
        cast(order_item_id as varchar) as order_item_id,
        cast(order_id as varchar) as order_id,
        cast(product_id as varchar) as product_id,
        cast(quantity as integer) as quantity,
        cast(unit_price as decimal(18, 2)) as unit_price,
        cast(coalesce(try_cast(discount_amount as decimal(18, 2)), 0) as decimal(18, 2)) as discount_amount
    from source
)

select * from renamed
