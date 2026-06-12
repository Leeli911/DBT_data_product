# Case Study: Trusted E-commerce Metrics with dbt

## Situation

E-commerce teams often define revenue, conversion, active users, and repeat purchase behavior differently across marketing, product, and finance dashboards. When analysts query raw events directly, metric logic becomes duplicated, hard to audit, and vulnerable to upstream tracking issues.

The classic anti-pattern is definition sprawl: marketing may reason from channel clicks, product may reason from sessions, and finance may reason from orders. This project shows how a version-controlled dbt workflow can reduce that friction before data reaches a dashboard.

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
- Added an order-to-session attribution bridge so revenue by channel can align with recomputed converting sessions when possible.
- Modeled `dim_users`, `dim_products`, `fact_orders`, and `fact_sessions` with explicit grains.
- Built `agg_daily_ecommerce_metrics` at `metric_date + traffic_source`.
- Stored metric components rather than final ratios to preserve additivity.
- Defined 8 governed e-commerce metrics with business definitions, SQL logic, grain, dimensions, and edge cases.
- Enforced marts-layer dbt contracts with explicit column names and data types.
- Added 150+ dbt tests, including primary key tests, relationship tests, accepted values, business assertion tests, attribution coverage, attribution status consistency, and reconciliation tests.
- Generated dbt docs and a GitHub-renderable lineage graph.

## Result

The project now provides a reproducible analytics engineering warehouse prototype:

```text
5 seeds
13 dbt models
150+ passing dbt tests
enforced marts-layer contracts
documented metric definitions
lineage-ready documentation
```

Latest local v2 validation reports `158` passing dbt tests. Public resume and portfolio copy should use the exact `158` count only after the v2 branch is merged to `main` and GitHub Actions confirms the same result.

The final marts and metric components can support self-service analytics without requiring every dashboard to reimplement deduplication, sessionization, revenue handling, or ratio logic.

## What This Proves

This project is not only a dashboard demo. It shows the practical analytics engineering workflow behind trusted reporting:

- raw data is cleaned and tested before reporting
- model grains are explicit
- facts and dimensions are contract-protected
- metrics are documented and governed
- ratio metrics are computed from valid numerator and denominator components
- aggregate models reconcile back to facts

## What I Learned and What I Would Improve

This project is intentionally portfolio-scale. The next production step would be to handle late-arriving events, larger event volumes, last non-direct touch, multi-touch attribution, incremental models, and BigQuery/GA4 nested `event_params` and `items` extraction.

The marts, metric definitions, contracts, and business tests are designed to remain as stable as possible while source and staging logic changes for a cloud warehouse.
