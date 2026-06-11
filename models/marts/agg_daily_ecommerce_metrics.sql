with sessions as (
    select * from {{ ref('fact_sessions') }}
),

users as (
    select * from {{ ref('dim_users') }}
),

orders as (
    select * from {{ ref('fact_orders') }}
),

sessions_enriched as (
    select
        sessions.session_date as metric_date,
        sessions.traffic_source,
        sessions.user_id,
        sessions.session_id,
        sessions.is_converted_session,
        sessions.page_views_count,
        sessions.product_views_count,
        sessions.add_to_cart_count,
        sessions.checkout_count,
        case
            when cast(users.first_active_at as date) = sessions.session_date then true
            else false
        end as is_new_active_user
    from sessions
    left join users
        on sessions.user_id = users.user_id
),

session_metrics as (
    select
        metric_date,
        traffic_source,
        count(*) as total_sessions,
        sum(case when is_converted_session then 1 else 0 end) as converted_sessions,
        count(distinct user_id) as active_users,
        count(distinct case when is_new_active_user then user_id end) as new_active_users,
        count(distinct case when not is_new_active_user then user_id end) as returning_active_users,
        sum(page_views_count) as page_views,
        sum(product_views_count) as product_views,
        sum(add_to_cart_count) as add_to_carts,
        sum(checkout_count) as checkouts
    from sessions_enriched
    group by 1, 2
),

orders_with_history as (
    select
        *,
        row_number() over (
            partition by user_id
            order by order_timestamp, order_id
        ) as valid_order_sequence
    from orders
    where order_status != 'cancelled'
),

order_metrics as (
    select
        order_date as metric_date,
        traffic_source,
        count(*) as valid_order_count,
        count(distinct user_id) as purchasing_users,
        count(distinct case when valid_order_sequence >= 2 then user_id end) as repeat_purchasing_users,
        sum(gmv_amount) as gmv_amount,
        sum(returned_amount) as returned_amount,
        sum(gross_item_amount) as gross_item_amount,
        sum(net_item_amount) as net_item_amount,
        sum(tax_amount) as tax_amount,
        sum(shipping_amount) as shipping_amount,
        sum(discount_amount) as discount_amount
    from orders_with_history
    group by 1, 2
),

cancelled_order_metrics as (
    select
        order_date as metric_date,
        traffic_source,
        count(*) as cancelled_order_count
    from orders
    where order_status = 'cancelled'
    group by 1, 2
),

combined as (
    select
        coalesce(session_metrics.metric_date, order_metrics.metric_date, cancelled_order_metrics.metric_date) as metric_date,
        coalesce(session_metrics.traffic_source, order_metrics.traffic_source, cancelled_order_metrics.traffic_source) as traffic_source,
        session_metrics.total_sessions,
        session_metrics.converted_sessions,
        session_metrics.active_users,
        session_metrics.new_active_users,
        session_metrics.returning_active_users,
        session_metrics.page_views,
        session_metrics.product_views,
        session_metrics.add_to_carts,
        session_metrics.checkouts,
        order_metrics.valid_order_count,
        cancelled_order_metrics.cancelled_order_count,
        order_metrics.purchasing_users,
        order_metrics.repeat_purchasing_users,
        order_metrics.gmv_amount,
        order_metrics.returned_amount,
        order_metrics.gross_item_amount,
        order_metrics.net_item_amount,
        order_metrics.tax_amount,
        order_metrics.shipping_amount,
        order_metrics.discount_amount
    from session_metrics
    full outer join order_metrics
        on session_metrics.metric_date = order_metrics.metric_date
        and session_metrics.traffic_source = order_metrics.traffic_source
    full outer join cancelled_order_metrics
        on coalesce(session_metrics.metric_date, order_metrics.metric_date) = cancelled_order_metrics.metric_date
        and coalesce(session_metrics.traffic_source, order_metrics.traffic_source) = cancelled_order_metrics.traffic_source
)

select
    metric_date,
    traffic_source,
    coalesce(total_sessions, 0) as total_sessions,
    coalesce(converted_sessions, 0) as converted_sessions,
    coalesce(active_users, 0) as active_users,
    coalesce(new_active_users, 0) as new_active_users,
    coalesce(returning_active_users, 0) as returning_active_users,
    coalesce(page_views, 0) as page_views,
    coalesce(product_views, 0) as product_views,
    coalesce(add_to_carts, 0) as add_to_carts,
    coalesce(checkouts, 0) as checkouts,
    coalesce(valid_order_count, 0) as valid_order_count,
    coalesce(cancelled_order_count, 0) as cancelled_order_count,
    coalesce(purchasing_users, 0) as purchasing_users,
    coalesce(repeat_purchasing_users, 0) as repeat_purchasing_users,
    cast(coalesce(gmv_amount, 0) as decimal(18, 2)) as gmv_amount,
    cast(coalesce(returned_amount, 0) as decimal(18, 2)) as returned_amount,
    cast(coalesce(gross_item_amount, 0) as decimal(18, 2)) as gross_item_amount,
    cast(coalesce(net_item_amount, 0) as decimal(18, 2)) as net_item_amount,
    cast(coalesce(tax_amount, 0) as decimal(18, 2)) as tax_amount,
    cast(coalesce(shipping_amount, 0) as decimal(18, 2)) as shipping_amount,
    cast(coalesce(discount_amount, 0) as decimal(18, 2)) as discount_amount
from combined
