with source as (
    select * from {{ ref('raw_products') }}
),

renamed as (
    select
        cast(product_id as varchar) as product_id,
        cast(product_name as varchar) as product_name,
        cast(category as varchar) as product_category,
        cast(subcategory as varchar) as product_subcategory,
        cast(brand as varchar) as product_brand,
        cast(list_price as decimal(18, 2)) as list_price,
        cast(is_active as boolean) as is_active
    from source
)

select * from renamed
