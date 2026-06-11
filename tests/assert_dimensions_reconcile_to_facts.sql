with user_fact_totals as (
    select
        user_id,
        count(*) as lifetime_orders,
        sum(case when order_status != 'cancelled' then total_revenue else 0 end) as lifetime_gmv
    from {{ ref('fact_orders') }}
    group by 1
),

user_dimension_mismatches as (
    select
        dim_users.user_id,
        'dim_users' as failing_model
    from {{ ref('dim_users') }} as dim_users
    left join user_fact_totals
        on dim_users.user_id = user_fact_totals.user_id
    where dim_users.lifetime_orders != coalesce(user_fact_totals.lifetime_orders, 0)
        or abs(dim_users.lifetime_gmv - coalesce(user_fact_totals.lifetime_gmv, 0)) > 0.01
),

product_fact_totals as (
    select
        product_id,
        count(*) as lifetime_order_lines,
        sum(quantity) as lifetime_quantity_sold,
        sum(gross_item_amount) as lifetime_gross_item_amount,
        sum(net_item_amount) as lifetime_net_item_amount
    from {{ ref('int_order_items_enriched') }}
    where order_status != 'cancelled'
    group by 1
),

product_dimension_mismatches as (
    select
        dim_products.product_id,
        'dim_products' as failing_model
    from {{ ref('dim_products') }} as dim_products
    left join product_fact_totals
        on dim_products.product_id = product_fact_totals.product_id
    where dim_products.lifetime_order_lines != coalesce(product_fact_totals.lifetime_order_lines, 0)
        or dim_products.lifetime_quantity_sold != coalesce(product_fact_totals.lifetime_quantity_sold, 0)
        or abs(dim_products.lifetime_gross_item_amount - coalesce(product_fact_totals.lifetime_gross_item_amount, 0)) > 0.01
        or abs(dim_products.lifetime_net_item_amount - coalesce(product_fact_totals.lifetime_net_item_amount, 0)) > 0.01
)

select * from user_dimension_mismatches
union all
select * from product_dimension_mismatches
