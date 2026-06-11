# Analytics Engineering Decisions

This document records implementation decisions and tradeoffs so the project can be explained clearly in interviews.

## Why DuckDB First

DuckDB keeps the first implementation local, fast, inexpensive, and easy to reproduce. It is a good fit for portfolio development because it supports analytical SQL workflows without requiring cloud setup.

## Why Staging, Intermediate, and Marts

The layered dbt structure separates source cleanup from reusable business logic and reporting-ready models:

- Staging models standardize raw fields and source-specific logic.
- Intermediate models hold reusable transformations.
- Marts expose facts, dimensions, and aggregates for analytics consumers.

## Model Grains

The current mart grains are:

- `dim_users`: one row per user.
- `dim_products`: one row per product.
- `fact_orders`: one row per order.
- `fact_sessions`: one row per recomputed user session.

The current attribution bridge grain is:

- `int_order_session_attribution`: one row per order.

The current aggregate grain is:

- `agg_daily_ecommerce_metrics`: one row per `metric_date` and `traffic_source`.

## Why Recompute Sessions

The project keeps `source_session_id` in staging, but the intermediate layer recomputes sessions using a 30-minute inactivity boundary. This demonstrates a classic product analytics pattern and avoids blindly trusting upstream telemetry session IDs.

The resulting `fact_sessions` model includes:

- `landing_page`
- `exit_page`
- event counts
- product interaction counts
- `is_converted_session`

## Current Metric Governance Decisions

- Cancelled orders are excluded from `gmv_amount` in `fact_orders`.
- Returned orders are retained and separately flagged through `is_returned_order` and `returned_amount`.
- Session conversion is based on whether a recomputed session contains a purchase event.
- Revenue by channel uses `attributed_traffic_source`, which links orders to recomputed sessions where possible and falls back to the original order-level source when no reliable session match exists.

## Why Ratio Metrics Are Not Stored Directly

Ratio metrics such as conversion rate, AOV, and repeat purchase rate are non-additive. The aggregate model stores additive components such as `converted_sessions`, `total_sessions`, `gmv_amount`, and `valid_order_count` so downstream tools can recompute ratios at the requested grain.

This avoids incorrect rollups such as averaging daily conversion rates with different denominators.

Future implementation should document:

- Which fields belong in an enforced data contract.
