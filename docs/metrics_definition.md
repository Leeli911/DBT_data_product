# Metrics Definition

This document defines the governed e-commerce metrics used by the project. Metrics are designed for semantic-layer readiness: aggregate tables preserve numerators and denominators, while ratios are calculated at query time.

## Source Models

- `fact_orders`: one row per order.
- `fact_sessions`: one row per recomputed user session.
- `int_order_session_attribution`: one row per order, assigning revenue attribution to a recomputed session when possible.
- `dim_users`: one row per user.
- `agg_daily_ecommerce_metrics`: one row per `metric_date` and `traffic_source`.

## Metrics

### GMV

- Business definition: Gross merchandise value from non-cancelled orders.
- Formula: `sum(gmv_amount)`.
- SQL logic:

```sql
select sum(gmv_amount) as gmv
from {{ ref('fact_orders') }}
where order_status != 'cancelled'
```

- Aggregate source: `sum(agg_daily_ecommerce_metrics.gmv_amount)`.
- Grain: order-level in `fact_orders`; daily channel-level in `agg_daily_ecommerce_metrics`.
- Valid dimensions: date, traffic source, user, order status, and product attributes through order-item analysis.
- Edge cases: Cancelled orders contribute `0` to GMV. Returned orders remain in GMV but are separately tracked with `returned_amount`.

### Orders

- Business definition: Count of non-cancelled orders.
- Formula: `count(order_id)` where `order_status != 'cancelled'`.
- SQL logic:

```sql
select count(*) as orders
from {{ ref('fact_orders') }}
where order_status != 'cancelled'
```

- Aggregate source: `sum(agg_daily_ecommerce_metrics.valid_order_count)`.
- Grain: order-level in `fact_orders`; daily channel-level in `agg_daily_ecommerce_metrics`.
- Valid dimensions: date, traffic source, user, order status.
- Edge cases: Cancelled orders are excluded from the core orders metric and tracked separately as `cancelled_order_count`.

### Active Users

- Business definition: Distinct users with at least one recomputed session in the selected period.
- Formula: `count(distinct user_id)` from sessions.
- SQL logic:

```sql
select count(distinct user_id) as active_users
from {{ ref('fact_sessions') }}
```

- Aggregate source: `agg_daily_ecommerce_metrics.active_users` at the stored date/channel grain.
- Grain: session-level in `fact_sessions`; daily channel-level in `agg_daily_ecommerce_metrics`.
- Valid dimensions: date, traffic source, device category, landing page, exit page.
- Edge cases: This metric is non-additive across dates and channels. To calculate weekly or monthly active users, query `fact_sessions` directly with `count(distinct user_id)`.

### Conversion Rate

- Business definition: Share of sessions that contain at least one purchase event.
- Formula: `converted_sessions / total_sessions`.
- SQL logic:

```sql
select
    sum(case when is_converted_session then 1 else 0 end) * 1.0
    / nullif(count(*), 0) as conversion_rate
from {{ ref('fact_sessions') }}
```

- Aggregate source: `sum(converted_sessions) / nullif(sum(total_sessions), 0)`.
- Grain: session-level in `fact_sessions`; daily channel-level components in `agg_daily_ecommerce_metrics`.
- Valid dimensions: date, traffic source, device category, landing page.
- Edge cases: Do not average precomputed daily conversion rates. Always recompute from total numerator and denominator.

### Average Order Value

- Business definition: Average GMV per non-cancelled order.
- Formula: `gmv_amount / valid_order_count`.
- SQL logic:

```sql
select
    sum(gmv_amount) / nullif(count(*), 0) as average_order_value
from {{ ref('fact_orders') }}
where order_status != 'cancelled'
```

- Aggregate source: `sum(gmv_amount) / nullif(sum(valid_order_count), 0)`.
- Grain: order-level in `fact_orders`; daily channel-level components in `agg_daily_ecommerce_metrics`.
- Valid dimensions: date, traffic source, user segment.
- Edge cases: AOV is non-additive. Never average AOV values across rows.

### Repeat Purchase Rate

- Business definition: Share of purchasing users whose current non-cancelled order is at least their second valid order.
- This is not a cohort retention metric. It measures the share of purchasing users at the reporting grain whose valid order on that date is their second or later valid order.
- Formula: `repeat_purchasing_users / purchasing_users`.
- SQL logic:

```sql
with orders_with_history as (
    select
        *,
        row_number() over (
            partition by user_id
            order by order_timestamp, order_id
        ) as valid_order_sequence
    from {{ ref('fact_orders') }}
    where order_status != 'cancelled'
)

select
    count(distinct case when valid_order_sequence >= 2 then user_id end) * 1.0
    / nullif(count(distinct user_id), 0) as repeat_purchase_rate
from orders_with_history
```

- Aggregate source: `sum(repeat_purchasing_users) / nullif(sum(purchasing_users), 0)` only at compatible grains.
- Grain: user-order history in `fact_orders`; daily channel-level components in `agg_daily_ecommerce_metrics`.
- Valid dimensions: date, traffic source, user segment.
- Edge cases: The aggregate version counts repeat status at purchase time, not lifetime status after the full dataset. For precise cohort repeat rates, build a cohort-specific model.

### New vs Returning Users

- Business definition: Split of active users by whether their first active date is the selected metric date.
- Formula: `new_active_users` and `returning_active_users`.
- SQL logic:

```sql
select
    count(distinct case when cast(dim_users.first_active_at as date) = fact_sessions.session_date then fact_sessions.user_id end) as new_active_users,
    count(distinct case when cast(dim_users.first_active_at as date) < fact_sessions.session_date then fact_sessions.user_id end) as returning_active_users
from {{ ref('fact_sessions') }} as fact_sessions
left join {{ ref('dim_users') }} as dim_users
    on fact_sessions.user_id = dim_users.user_id
```

- Aggregate source: `new_active_users` and `returning_active_users` in `agg_daily_ecommerce_metrics`.
- Grain: session/user-level in marts; daily channel-level in the aggregate table.
- Valid dimensions: date, traffic source, device category.
- Edge cases: These user counts are not additive across channels because one user can appear in more than one channel.

### Revenue by Channel

- Business definition: GMV grouped by the attributed traffic source assigned by `int_order_session_attribution`.
- Formula: `sum(gmv_amount) group by traffic_source`.
- SQL logic:

```sql
select
    attributed_traffic_source,
    sum(gmv_amount) as revenue
from {{ ref('fact_orders') }}
where order_status != 'cancelled'
group by 1
```

- Aggregate source: `sum(agg_daily_ecommerce_metrics.gmv_amount) group by traffic_source`.
- Grain: order-level in `fact_orders`; daily channel-level in `agg_daily_ecommerce_metrics`.
- Valid dimensions: date and traffic source.
- Edge cases: Orders are first attributed through purchase-event session matches, then timestamp-window matches, then order-source fallback. A production system may need late-event handling, last non-direct click, or multi-touch attribution rules.
