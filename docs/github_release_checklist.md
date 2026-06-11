# GitHub Release Checklist

Use this checklist before publishing the repository.

## Repository Hygiene

- [ ] Confirm `.venv/`, `target/`, `logs/`, `warehouse/`, `profiles.yml`, and `*.duckdb` are ignored.
- [ ] Confirm no local secrets or personal credentials are committed.
- [ ] Confirm `profiles.example.yml` is safe to publish.
- [ ] Confirm generated dbt artifacts under `target/` are not committed.
- [ ] Confirm README links render correctly on GitHub.

## Validation

Run:

```bash
./run_project.sh
dbt docs generate
```

Expected result:

```text
dbt seed: PASS=5 WARN=0 ERROR=0
dbt run:  PASS=12 WARN=0 ERROR=0
dbt test: PASS=140 WARN=0 ERROR=0
dbt docs generate: completed successfully
```

## Optional Screenshot Capture

Run:

```bash
dbt docs serve --port 8080
```

Capture screenshots:

- `docs/assets/dbt-lineage-marts.png`
- `docs/assets/dbt-test-results.png`
- `docs/assets/aggregate-query-results.png`

The committed Markdown evidence can be used until screenshots are added:

- `docs/lineage.md`
- `docs/assets/test_results_summary.md`
- `docs/assets/channel_metrics_snapshot.md`

## Suggested GitHub Description

Analytics engineering portfolio project using dbt and DuckDB to build trusted e-commerce metrics, data contracts, and self-service-ready marts.

## Suggested Topics

- dbt
- duckdb
- analytics-engineering
- data-contracts
- metric-layer
- dimensional-modeling
- ecommerce-analytics
- data-quality

## Suggested First Commit Message

```text
Build trusted ecommerce metrics dbt portfolio
```
