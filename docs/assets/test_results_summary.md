# Test Results Summary

Latest validation from `./run_project.sh`:

```text
dbt seed: PASS=5 WARN=0 ERROR=0
dbt run:  PASS=13 WARN=0 ERROR=0
dbt test: PASS=157 WARN=0 ERROR=0
dbt docs generate: completed successfully
```

Coverage includes:

- staging primary keys and accepted values
- intermediate session and order-item uniqueness
- order-to-session attribution coverage and accepted values
- marts primary keys and foreign keys
- enforced marts-layer model contracts
- aggregate metric component validation
- fact-to-aggregate reconciliation at `metric_date + traffic_source`
- dimension-to-fact reconciliation
- order and session business rules
