# Portfolio Summary

## Project Title

Trusted E-commerce Metrics with dbt

## Short Description

A dbt + DuckDB analytics engineering project that turns raw e-commerce orders and event data into trusted facts, dimensions, and governed metric components.

## Long Description

This project simulates a modern analytics engineering workflow for an e-commerce business. Synthetic raw data is modeled through staging, intermediate, and marts layers, then exposed through contracted facts, dimensions, and additive metric components.

The project focuses on how trusted business metrics are modeled, tested, and documented before they reach dashboards. It demonstrates how to handle event deduplication, sessionization, dimensional modeling, data contracts, business assertion tests, attribution consistency, and additivity-safe metric design.

## Highlights

- Modeled raw e-commerce events into staging, intermediate, and marts layers.
- Implemented 30-minute inactivity-based sessionization.
- Added order-to-session attribution for channel revenue consistency.
- Built `fact_orders`, `fact_sessions`, `dim_users`, `dim_products`, and `agg_daily_ecommerce_metrics`.
- Defined 8 core e-commerce metrics with business logic and edge cases.
- Enforced marts-layer dbt contracts.
- Added 150+ passing dbt tests, with the latest local v2 validation reporting 158.
- Generated dbt docs and lineage-ready evidence.
- Designed the local DuckDB implementation with a clear BigQuery/GA4 migration path.

## Tech Stack

- dbt Core
- dbt-duckdb
- DuckDB
- SQL
- Python 3.10
- uv

## Suggested Portfolio Card

**Trusted E-commerce Metrics with dbt**

```text
A dbt + DuckDB analytics engineering project that turns raw e-commerce orders and events into trusted facts, dimensions, and metric components.

Built with 30-minute sessionization, order-to-session attribution, dbt contracts, 150+ tests, and GitHub Actions CI.

Tech stack: dbt, DuckDB, SQL, GitHub Actions, Python
```

After v2 is merged to `main` and GitHub Actions confirms the current count, update `150+ tests` to `158 passing tests`.

## Suggested Case Study Page

1. Problem: marketing, product, and finance can disagree when each team rebuilds metrics from raw data.
2. Architecture: raw seeds -> staging -> intermediate -> marts -> trusted metric components.
3. Core Modeling: `fact_orders`, `fact_sessions`, `dim_users`, `dim_products`, and `agg_daily_ecommerce_metrics`.
4. Attribution Highlight: `int_order_session_attribution` assigns revenue to a converting session when possible.
5. Metric Governance: GMV, conversion rate, AOV, repeat purchase rate, and revenue by channel are built from auditable components.
6. Quality Evidence: 13 dbt models, 5 seed tables, enforced contracts, GitHub Actions CI, and 150+ tests.
7. What I Learned and What I Would Improve: late events, last non-direct touch, multi-touch attribution, incremental models, and BigQuery/GA4 nested event fields.

Use `Net Item Amount` if showing a net money field. Avoid calling it `Net Revenue` unless tax, shipping, discounts, returns, and refund timing are explicitly defined.

## Suggested Project Links

- GitHub repository
- dbt lineage page: `docs/lineage.md`
- Case study: `docs/case_study.md`
- Metrics definition: `docs/metrics_definition.md`
- Data contracts: `docs/data_contracts.md`
- Interview prep: `docs/interview_prep.md`
