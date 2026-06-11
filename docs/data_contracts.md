# Data Contracts

This document describes the project data contracts and how dbt tests enforce trusted reporting surfaces.

## Contract Goals

Data contracts make the marts layer safe for self-service analytics by defining:

- Expected model grain.
- Required columns.
- Column data types.
- Primary keys.
- Foreign key relationships.
- Accepted enum values.
- Business-critical nullability rules.
- Business logic assertions that prevent silent metric drift.

## Enforced Mart Contracts

The marts layer uses dbt model contracts with:

```yaml
config:
  contract:
    enforced: true
```

Contracts are enforced for:

- `dim_users`
- `dim_products`
- `fact_orders`
- `fact_sessions`
- `agg_daily_ecommerce_metrics`

Each contracted model declares its full output column list and DuckDB-compatible data types in `models/marts/schema.yml`. If a model SQL file adds, removes, renames, or changes the type of a contracted column without updating the contract, `dbt run` fails before downstream reporting can consume the broken shape.

## Primary Grain Contracts

- `dim_users`: one row per `user_id`.
- `dim_products`: one row per `product_id`.
- `fact_orders`: one row per `order_id`.
- `fact_sessions`: one row per recomputed `session_id`.
- `agg_daily_ecommerce_metrics`: one row per `metric_date` and `traffic_source`.

## Defensive Tests

The project enforces:

- Primary key uniqueness and non-null tests.
- User foreign-key relationships from facts to `dim_users`.
- Accepted values for order status and traffic source.
- Non-null tests for metric components, facts, dimensions, and aggregate fields.
- Business assertions for order status flags, GMV logic, returned-order logic, session conversion logic, session timing, and aggregate reconciliation.

## Business Assertion Tests

Custom tests in `tests/` include:

- `assert_fact_orders_business_rules.sql`: validates cancelled orders, returned orders, GMV, order-line counts, quantities, and non-negative amounts.
- `assert_order_session_attribution_covers_all_orders.sql`: validates that every staged order has exactly one attribution bridge row.
- `assert_fact_sessions_business_rules.sql`: validates session time windows, event counts, purchase counts, conversion flags, and first order IDs.
- `assert_agg_daily_ecommerce_metrics_unique_grain.sql`: enforces the daily channel aggregate grain.
- `assert_agg_daily_ecommerce_metrics_valid_components.sql`: prevents invalid ratio components such as converted sessions exceeding total sessions.
- `assert_agg_daily_ecommerce_metrics_reconciles_to_facts.sql`: reconciles aggregate rows back to `fact_orders` and `fact_sessions` at `metric_date + traffic_source`.
- `assert_dimensions_reconcile_to_facts.sql`: reconciles dimension lifetime summaries back to facts and enriched order items.

## Current Status

Data contracts are implemented and passing. Latest validation:

```text
dbt seed: PASS=5 WARN=0 ERROR=0
dbt run:  PASS=13 WARN=0 ERROR=0
dbt test: PASS=157 WARN=0 ERROR=0
```
