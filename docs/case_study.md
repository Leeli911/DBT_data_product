# Case Study: Trusted E-commerce Metrics with dbt

## Situation

E-commerce teams often define revenue, conversion, active users, and repeat purchase behavior differently across marketing, product, and finance dashboards. When analysts query raw events directly, metric logic becomes duplicated, hard to audit, and vulnerable to upstream tracking issues.

## Task

Build a small but complete analytics engineering project that converts raw e-commerce events and transactions into trusted marts, governed metric definitions, and a self-service-ready reporting foundation.

The project needed to demonstrate:

- modular dbt modeling
- dimensional modeling
- data quality tests
- data contracts
- metric governance
- lineage-ready documentation

## Action

I implemented a local-first dbt project with DuckDB and synthetic GA4-like seed data. The raw data includes duplicate telemetry events, cancelled orders, returned orders, missing revenue, multiple traffic sources, and product/category attributes.

Key engineering decisions:

- Built a three-layer dbt structure: staging, intermediate, and marts.
- Standardized raw fields and deduplicated events in staging.
- Recomputed sessions with a 30-minute inactivity boundary instead of blindly trusting source session IDs.
- Modeled `dim_users`, `dim_products`, `fact_orders`, and `fact_sessions` with explicit grains.
- Built `agg_daily_ecommerce_metrics` at `metric_date + traffic_source`.
- Stored metric components rather than final ratios to preserve additivity.
- Defined 8 governed e-commerce metrics with business definitions, SQL logic, grain, dimensions, and edge cases.
- Enforced marts-layer dbt contracts with explicit column names and data types.
- Added 140 dbt tests, including primary key tests, relationship tests, accepted values, business assertion tests, and reconciliation tests.
- Generated dbt docs and a GitHub-renderable lineage graph.

## Result

The project now provides a reproducible analytics engineering warehouse prototype:

```text
5 seeds
12 dbt models
140 passing dbt tests
enforced marts-layer contracts
documented metric definitions
lineage-ready documentation
```

The final marts and metric components can support self-service analytics without requiring every dashboard to reimplement deduplication, sessionization, revenue handling, or ratio logic.

## What This Proves

This project is not only a dashboard demo. It shows the practical analytics engineering workflow behind trusted reporting:

- raw data is cleaned and tested before reporting
- model grains are explicit
- facts and dimensions are contract-protected
- metrics are documented and governed
- ratio metrics are computed from valid numerator and denominator components
- aggregate models reconcile back to facts

## Future Production Extension

In a production BigQuery/GA4 environment, the main migration work would be in source and staging models, especially nested `event_params` and `items` extraction. The marts, metric definitions, contracts, and business tests are designed to remain as stable as possible.
