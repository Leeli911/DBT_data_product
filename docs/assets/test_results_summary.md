# Test Results Summary

Latest validation from `./run_project.sh`:

```text
dbt seed: PASS=5 WARN=0 ERROR=0
dbt run:  PASS=12 WARN=0 ERROR=0
dbt test: PASS=140 WARN=0 ERROR=0
dbt docs generate: completed successfully
```

Coverage includes:

- staging primary keys and accepted values
- intermediate session and order-item uniqueness
- marts primary keys and foreign keys
- enforced marts-layer model contracts
- aggregate metric component validation
- fact-to-aggregate reconciliation
- dimension-to-fact reconciliation
- order and session business rules
