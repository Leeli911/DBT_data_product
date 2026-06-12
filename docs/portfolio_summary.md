# Portfolio Summary

## Project Title

Trusted E-commerce Metrics: Analytics Engineering with dbt and DuckDB

## Short Description

Built a local-first analytics engineering project that transforms raw e-commerce events and transactions into tested marts, governed metric components, and self-service-ready documentation using dbt and DuckDB.

## Long Description

This project simulates a modern analytics engineering workflow for an e-commerce business. Synthetic raw data is modeled through staging, intermediate, and marts layers, then exposed through contracted facts, dimensions, and additive metric components.

The project focuses on metric trust rather than dashboard decoration. It demonstrates how to handle event deduplication, sessionization, dimensional modeling, data contracts, business assertion tests, and additivity-safe metric design.

## Highlights

- Modeled raw e-commerce events into staging, intermediate, and marts layers.
- Implemented 30-minute inactivity-based sessionization.
- Added order-to-session attribution for channel revenue consistency.
- Built `fact_orders`, `fact_sessions`, `dim_users`, `dim_products`, and `agg_daily_ecommerce_metrics`.
- Defined 8 core e-commerce metrics with business logic and edge cases.
- Enforced marts-layer dbt contracts.
- Added 158 passing dbt tests.
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

**Trusted E-commerce Metrics**

Analytics engineering project using dbt and DuckDB to transform raw e-commerce events into tested marts, governed metrics, and data contracts. Includes 13 dbt models, 158 passing tests, order-to-session attribution, additive metric components, and lineage-ready documentation.

## Suggested Project Links

- GitHub repository
- dbt lineage page: `docs/lineage.md`
- Case study: `docs/case_study.md`
- Metrics definition: `docs/metrics_definition.md`
- Data contracts: `docs/data_contracts.md`
