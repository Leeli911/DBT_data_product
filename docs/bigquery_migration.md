# BigQuery Migration Notes

This project starts with DuckDB for local development speed and cost control. The migration target is a BigQuery warehouse using GA4-style e-commerce event data.

## Migration Principle

The project should not claim zero-code migration from DuckDB to BigQuery. DuckDB CSV seeds and BigQuery GA4 exports have different source shapes and SQL dialect details.

The stable parts should be:

- Business metric definitions.
- Model layer boundaries.
- Fact and dimension grains.
- Data quality expectations.
- Documentation and data contract intent.

The parts expected to change are:

- Source definitions.
- Staging models.
- GA4 nested field extraction.
- BigQuery-specific date, timestamp, and array syntax.

## GA4 Alignment Goals

The local seed design should mirror GA4 e-commerce concepts without copying the nested physical layout:

- `event_id`
- `event_name`
- `event_timestamp`
- `user_id`
- `session_id`
- `traffic_source`
- `page_location`
- `product_id`
- `order_id`
- `revenue`

In BigQuery, fields such as product items and custom parameters often require `UNNEST(event_params)` or `UNNEST(items)`. The BigQuery implementation should isolate that work in the staging layer so downstream marts and metrics remain stable.

## Future Adapter Plan

Future BigQuery work should add:

- `dbt-bigquery` to the dependency set.
- A separate `profiles.bigquery.example.yml`.
- BigQuery source definitions for the GA4 public e-commerce dataset.
- BigQuery-specific staging models for nested field extraction.
- A parity checklist comparing DuckDB marts with BigQuery marts.
