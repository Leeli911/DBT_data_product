# Metric Layer Design

This project treats the metrics layer as a governed interface between dbt marts and downstream BI tools. The goal is to make trusted metrics easy to query without hiding important grain and additivity constraints.

## Aggregate Table Grain

`agg_daily_ecommerce_metrics` is stored at:

```text
metric_date + traffic_source
```

This grain supports daily trend analysis and channel reporting while keeping the table compact enough for portfolio inspection.

## Additivity Rules

The aggregate table stores additive components, not final ratio metrics.

Stored examples:

- `total_sessions`
- `converted_sessions`
- `valid_order_count`
- `cancelled_order_count`
- `purchasing_users`
- `repeat_purchasing_users`
- `gmv_amount`
- `returned_amount`

Not stored as final columns:

- `conversion_rate`
- `average_order_value`
- `repeat_purchase_rate`
- percentage of new users

Those metrics should be calculated from numerator and denominator at query time.

## Metric Type Classification

### Additive

Can be summed across the aggregate table grain:

- GMV, when using `gmv_amount`.
- Valid order count.
- Cancelled order count.
- Converted sessions.
- Total sessions.
- Page views.
- Product views.
- Add-to-carts.
- Checkouts.

### Semi-additive

Can be used safely at the stored grain, but needs care when rolled up:

- `purchasing_users`
- `repeat_purchasing_users`
- `new_active_users`
- `returning_active_users`

These are distinct user counts at the aggregate row grain. They should not be blindly summed across overlapping channels or longer time windows if exact unique users are required.

### Non-additive

Must be recomputed from components:

- `conversion_rate = sum(converted_sessions) / sum(total_sessions)`
- `average_order_value = sum(gmv_amount) / sum(valid_order_count)`
- `repeat_purchase_rate = sum(repeat_purchasing_users) / sum(purchasing_users)`
- `new_user_share = sum(new_active_users) / sum(active_users)`

## BI Query Examples

Conversion rate by channel:

```sql
select
    traffic_source,
    sum(converted_sessions) * 1.0 / nullif(sum(total_sessions), 0) as conversion_rate
from analytics.agg_daily_ecommerce_metrics
group by 1
```

AOV by date:

```sql
select
    metric_date,
    sum(gmv_amount) / nullif(sum(valid_order_count), 0) as average_order_value
from analytics.agg_daily_ecommerce_metrics
group by 1
```

Revenue by channel:

```sql
select
    traffic_source,
    sum(gmv_amount) as revenue
from analytics.agg_daily_ecommerce_metrics
group by 1
```

## Design Guardrail

If a dashboard needs exact distinct users across multiple dates, channels, or cohorts, it should query `fact_sessions` or a purpose-built user-grain aggregate instead of summing daily channel-level distinct counts.
