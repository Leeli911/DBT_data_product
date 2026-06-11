with aggregate_by_grain as (
    select
        metric_date,
        traffic_source,
        total_sessions,
        converted_sessions,
        active_users,
        new_active_users,
        returning_active_users,
        page_views,
        product_views,
        add_to_carts,
        checkouts,
        valid_order_count,
        cancelled_order_count,
        purchasing_users,
        repeat_purchasing_users,
        gmv_amount,
        returned_amount,
        gross_item_amount,
        net_item_amount,
        tax_amount,
        shipping_amount,
        discount_amount
    from {{ ref('agg_daily_ecommerce_metrics') }}
),

sessions as (
    select * from {{ ref('fact_sessions') }}
),

users as (
    select * from {{ ref('dim_users') }}
),

orders as (
    select * from {{ ref('fact_orders') }}
),

session_expected as (
    select
        sessions.session_date as metric_date,
        sessions.traffic_source,
        count(*) as total_sessions,
        sum(case when sessions.is_converted_session then 1 else 0 end) as converted_sessions,
        count(distinct sessions.user_id) as active_users,
        count(distinct case when cast(users.first_active_at as date) = sessions.session_date then sessions.user_id end) as new_active_users,
        count(distinct case when cast(users.first_active_at as date) != sessions.session_date then sessions.user_id end) as returning_active_users,
        sum(sessions.page_views_count) as page_views,
        sum(sessions.product_views_count) as product_views,
        sum(sessions.add_to_cart_count) as add_to_carts,
        sum(sessions.checkout_count) as checkouts
    from sessions
    left join users
        on sessions.user_id = users.user_id
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

order_expected as (
    select
        order_date as metric_date,
        attributed_traffic_source as traffic_source,
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

cancelled_expected as (
    select
        order_date as metric_date,
        attributed_traffic_source as traffic_source,
        count(*) as cancelled_order_count
    from orders
    where order_status = 'cancelled'
    group by 1, 2
),

expected_by_grain as (
    select
        coalesce(session_expected.metric_date, order_expected.metric_date, cancelled_expected.metric_date) as metric_date,
        coalesce(session_expected.traffic_source, order_expected.traffic_source, cancelled_expected.traffic_source) as traffic_source,
        coalesce(session_expected.total_sessions, 0) as total_sessions,
        coalesce(session_expected.converted_sessions, 0) as converted_sessions,
        coalesce(session_expected.active_users, 0) as active_users,
        coalesce(session_expected.new_active_users, 0) as new_active_users,
        coalesce(session_expected.returning_active_users, 0) as returning_active_users,
        coalesce(session_expected.page_views, 0) as page_views,
        coalesce(session_expected.product_views, 0) as product_views,
        coalesce(session_expected.add_to_carts, 0) as add_to_carts,
        coalesce(session_expected.checkouts, 0) as checkouts,
        coalesce(order_expected.valid_order_count, 0) as valid_order_count,
        coalesce(cancelled_expected.cancelled_order_count, 0) as cancelled_order_count,
        coalesce(order_expected.purchasing_users, 0) as purchasing_users,
        coalesce(order_expected.repeat_purchasing_users, 0) as repeat_purchasing_users,
        cast(coalesce(order_expected.gmv_amount, 0) as decimal(18, 2)) as gmv_amount,
        cast(coalesce(order_expected.returned_amount, 0) as decimal(18, 2)) as returned_amount,
        cast(coalesce(order_expected.gross_item_amount, 0) as decimal(18, 2)) as gross_item_amount,
        cast(coalesce(order_expected.net_item_amount, 0) as decimal(18, 2)) as net_item_amount,
        cast(coalesce(order_expected.tax_amount, 0) as decimal(18, 2)) as tax_amount,
        cast(coalesce(order_expected.shipping_amount, 0) as decimal(18, 2)) as shipping_amount,
        cast(coalesce(order_expected.discount_amount, 0) as decimal(18, 2)) as discount_amount
    from session_expected
    full outer join order_expected
        on session_expected.metric_date = order_expected.metric_date
        and session_expected.traffic_source = order_expected.traffic_source
    full outer join cancelled_expected
        on coalesce(session_expected.metric_date, order_expected.metric_date) = cancelled_expected.metric_date
        and coalesce(session_expected.traffic_source, order_expected.traffic_source) = cancelled_expected.traffic_source
),

comparison as (
    select
        coalesce(aggregate_by_grain.metric_date, expected_by_grain.metric_date) as metric_date,
        coalesce(aggregate_by_grain.traffic_source, expected_by_grain.traffic_source) as traffic_source,
        aggregate_by_grain.total_sessions as actual_total_sessions,
        expected_by_grain.total_sessions as expected_total_sessions,
        aggregate_by_grain.converted_sessions as actual_converted_sessions,
        expected_by_grain.converted_sessions as expected_converted_sessions,
        aggregate_by_grain.active_users as actual_active_users,
        expected_by_grain.active_users as expected_active_users,
        aggregate_by_grain.new_active_users as actual_new_active_users,
        expected_by_grain.new_active_users as expected_new_active_users,
        aggregate_by_grain.returning_active_users as actual_returning_active_users,
        expected_by_grain.returning_active_users as expected_returning_active_users,
        aggregate_by_grain.page_views as actual_page_views,
        expected_by_grain.page_views as expected_page_views,
        aggregate_by_grain.product_views as actual_product_views,
        expected_by_grain.product_views as expected_product_views,
        aggregate_by_grain.add_to_carts as actual_add_to_carts,
        expected_by_grain.add_to_carts as expected_add_to_carts,
        aggregate_by_grain.checkouts as actual_checkouts,
        expected_by_grain.checkouts as expected_checkouts,
        aggregate_by_grain.valid_order_count as actual_valid_order_count,
        expected_by_grain.valid_order_count as expected_valid_order_count,
        aggregate_by_grain.cancelled_order_count as actual_cancelled_order_count,
        expected_by_grain.cancelled_order_count as expected_cancelled_order_count,
        aggregate_by_grain.purchasing_users as actual_purchasing_users,
        expected_by_grain.purchasing_users as expected_purchasing_users,
        aggregate_by_grain.repeat_purchasing_users as actual_repeat_purchasing_users,
        expected_by_grain.repeat_purchasing_users as expected_repeat_purchasing_users,
        aggregate_by_grain.gmv_amount as actual_gmv_amount,
        expected_by_grain.gmv_amount as expected_gmv_amount,
        aggregate_by_grain.returned_amount as actual_returned_amount,
        expected_by_grain.returned_amount as expected_returned_amount,
        aggregate_by_grain.gross_item_amount as actual_gross_item_amount,
        expected_by_grain.gross_item_amount as expected_gross_item_amount,
        aggregate_by_grain.net_item_amount as actual_net_item_amount,
        expected_by_grain.net_item_amount as expected_net_item_amount,
        aggregate_by_grain.tax_amount as actual_tax_amount,
        expected_by_grain.tax_amount as expected_tax_amount,
        aggregate_by_grain.shipping_amount as actual_shipping_amount,
        expected_by_grain.shipping_amount as expected_shipping_amount,
        aggregate_by_grain.discount_amount as actual_discount_amount,
        expected_by_grain.discount_amount as expected_discount_amount
    from aggregate_by_grain
    full outer join expected_by_grain
        on aggregate_by_grain.metric_date = expected_by_grain.metric_date
        and aggregate_by_grain.traffic_source = expected_by_grain.traffic_source
)

select *
from comparison
where coalesce(actual_total_sessions, 0) != coalesce(expected_total_sessions, 0)
    or coalesce(actual_converted_sessions, 0) != coalesce(expected_converted_sessions, 0)
    or coalesce(actual_active_users, 0) != coalesce(expected_active_users, 0)
    or coalesce(actual_new_active_users, 0) != coalesce(expected_new_active_users, 0)
    or coalesce(actual_returning_active_users, 0) != coalesce(expected_returning_active_users, 0)
    or coalesce(actual_page_views, 0) != coalesce(expected_page_views, 0)
    or coalesce(actual_product_views, 0) != coalesce(expected_product_views, 0)
    or coalesce(actual_add_to_carts, 0) != coalesce(expected_add_to_carts, 0)
    or coalesce(actual_checkouts, 0) != coalesce(expected_checkouts, 0)
    or coalesce(actual_valid_order_count, 0) != coalesce(expected_valid_order_count, 0)
    or coalesce(actual_cancelled_order_count, 0) != coalesce(expected_cancelled_order_count, 0)
    or coalesce(actual_purchasing_users, 0) != coalesce(expected_purchasing_users, 0)
    or coalesce(actual_repeat_purchasing_users, 0) != coalesce(expected_repeat_purchasing_users, 0)
    or abs(coalesce(actual_gmv_amount, 0) - coalesce(expected_gmv_amount, 0)) > 0.01
    or abs(coalesce(actual_returned_amount, 0) - coalesce(expected_returned_amount, 0)) > 0.01
    or abs(coalesce(actual_gross_item_amount, 0) - coalesce(expected_gross_item_amount, 0)) > 0.01
    or abs(coalesce(actual_net_item_amount, 0) - coalesce(expected_net_item_amount, 0)) > 0.01
    or abs(coalesce(actual_tax_amount, 0) - coalesce(expected_tax_amount, 0)) > 0.01
    or abs(coalesce(actual_shipping_amount, 0) - coalesce(expected_shipping_amount, 0)) > 0.01
    or abs(coalesce(actual_discount_amount, 0) - coalesce(expected_discount_amount, 0)) > 0.01
