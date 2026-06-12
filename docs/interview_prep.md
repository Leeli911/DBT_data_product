# Interview Prep: Trusted E-commerce Metrics with dbt

This guide explains the five parts of the project that are most likely to come up in an Analytics Engineering interview. The goal is not to memorize every line of SQL; the goal is to explain the design choices clearly.

## 1. How the dbt Layers Work

Relevant files:

- `dbt_project.yml`
- `models/staging/`
- `models/intermediate/`
- `models/marts/`

Plain explanation:

```text
Staging standardizes raw fields and data types. Intermediate models contain reusable business logic such as sessionization and attribution. Marts expose facts, dimensions, and aggregate metric components for analytics.
```

Interview answer:

```text
I separated transformation logic into staging, intermediate, and marts layers. Staging keeps source cleanup close to raw data, intermediate models make complex business logic reusable, and marts provide stable business-facing tables with explicit grains and contracts.
```

What to point to:

- `stg_events`, `stg_orders`, `stg_order_items`, `stg_products`, `stg_users`
- `int_user_sessions`, `int_order_items_enriched`, `int_order_session_attribution`
- `fact_orders`, `fact_sessions`, `dim_users`, `dim_products`, `agg_daily_ecommerce_metrics`

## 2. How Sessionization Works

Relevant file:

- `models/intermediate/int_user_sessions.sql`

Plain explanation:

```text
For each user, I sort events by timestamp. If the gap from the previous event is more than 30 minutes, I start a new session. Then I group events into sessions and calculate landing page, exit page, duration, and conversion flags.
```

Core SQL idea:

```sql
lag(event_timestamp) over (
    partition by user_id
    order by event_timestamp
) as previous_event_timestamp
```

Interview answer:

```text
I used window functions to recompute sessions from event data. The model compares each event with the previous event for the same user. A gap of more than 30 minutes starts a new session, and a cumulative sum turns those boundaries into stable session ids.
```

Important limitation:

```text
At very large scale, sessionization can become expensive because window functions partition by user. In a production BigQuery or GA4 environment, I would first evaluate source session identifiers such as ga_session_id and then use incremental processing or date/hash partitioning if custom sessionization were still required.
```

## 3. How Order-to-Session Attribution Works

Relevant file:

- `models/intermediate/int_order_session_attribution.sql`

Plain explanation:

```text
The attribution bridge gives each order one attributed traffic source. It first tries to match an order to a purchase event inside a recomputed session. If that fails, it checks whether the order timestamp falls inside a session window for the same user. If that also fails, it falls back to the order-level traffic source.
```

Priority order:

```text
1. purchase_event_match
2. timestamp_window_match
3. order_source_fallback
```

Key fields:

```text
converting_session_id
session_traffic_source
order_traffic_source
attributed_traffic_source
attribution_method
attribution_status
```

Core SQL idea:

```sql
row_number() over (
    partition by order_id
    order by
        case
            when attribution_method = 'purchase_event_match' then 1
            when attribution_method = 'timestamp_window_match' then 2
            else 3
        end,
        session_end_at desc,
        session_start_at desc,
        converting_session_id
) as attribution_rank
```

Interview answer:

```text
I separated attribution method from attribution status. Method explains how the traffic source was assigned. Status explains whether the order was actually linked to a recomputed session or only fell back to the order-level source.
```

Limitation answer:

```text
This portfolio version uses a converting-session attribution bridge. In production, I would extend it to handle late events and multi-touch attribution, such as last non-direct touch, time-decay, or position-based rules.
```

## 4. Why Ratio Metrics Are Not Stored Directly

Relevant files:

- `models/marts/agg_daily_ecommerce_metrics.sql`
- `docs/metrics_definition.md`
- `docs/metric_layer_design.md`

Plain explanation:

```text
Ratios such as conversion rate, AOV, and repeat purchase rate should not be averaged across days or channels. The aggregate table stores numerator and denominator components so the final ratio can be recalculated at the reporting grain.
```

Examples:

```text
conversion_rate = sum(converted_sessions) / sum(total_sessions)
aov = sum(gmv_amount) / sum(valid_order_count)
repeat_purchase_rate = sum(repeat_purchasing_users) / sum(purchasing_users)
```

Interview answer:

```text
I designed the aggregate model for additivity. Instead of storing final conversion rates or AOV values, it stores atomic components. That prevents BI users from averaging ratios across incompatible denominators.
```

Repeat purchase clarification:

```text
Repeat purchase rate in this project is not a cohort retention metric. It measures the share of purchasing users at the reporting grain whose valid order on that date is their second or later valid order.
```

## 5. How Tests, Contracts, and CI Work

Relevant files:

- `models/marts/schema.yml`
- `models/intermediate/schema.yml`
- `tests/`
- `.github/workflows/dbt-ci.yml`
- `run_project.sh`

Plain explanation:

```text
The project uses dbt tests for primary keys, non-null rules, relationships, accepted values, attribution coverage, attribution status consistency, business rules, and fact-to-aggregate reconciliation. GitHub Actions runs the project on push and pull request.
```

Local command:

```bash
./run_project.sh
dbt docs generate --profiles-dir .
```

Interview answer:

```text
I treat tests as part of the metric contract. The CI workflow verifies that seed, run, test, and docs generation work outside my laptop. That makes the project reproducible for a reviewer or hiring team.
```

Public proof rule:

```text
Use 150+ dbt tests in public copy until v2 is merged to main and GitHub Actions confirms the exact count. After main CI passes, use the confirmed exact count.
```
