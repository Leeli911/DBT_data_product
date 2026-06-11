# Portfolio Evidence

This document lists the evidence assets that should be captured before publishing the project to GitHub or a personal portfolio site.

## Generated dbt Docs

Generate the docs site locally:

```bash
dbt docs generate
dbt docs serve --port 8080
```

The generated site is a local build artifact under `target/` and should not be committed.

Because local browser access may depend on workstation permissions, the repository also includes a GitHub-renderable lineage page at `docs/lineage.md` and the Mermaid source at `docs/assets/dbt_lineage_graph.mmd`.

## Validation Evidence

Latest validation:

```text
dbt seed: PASS=5 WARN=0 ERROR=0
dbt run:  PASS=12 WARN=0 ERROR=0
dbt test: PASS=140 WARN=0 ERROR=0
dbt docs generate: completed successfully
```

## Screenshot Checklist

Save screenshots under `docs/assets/` with these filenames:

- `dbt-lineage-marts.png`: lineage graph showing raw seeds through staging, intermediate, marts, and aggregate metrics.
- `dbt-test-results.png`: terminal output or dbt docs evidence showing 140 passing tests.
- `aggregate-query-results.png`: query result showing channel-level GMV, valid orders, conversion rate, and AOV calculated from additive components.

If screenshots are not available yet, use these committed evidence files:

- `docs/lineage.md`
- `docs/assets/dbt_lineage_graph.mmd`
- `docs/assets/test_results_summary.md`
- `docs/assets/channel_metrics_snapshot.md`

## Suggested README Placement

After screenshots are captured, add a short Evidence section to the README:

```markdown
## Evidence

![dbt lineage](docs/assets/dbt-lineage-marts.png)
![dbt tests](docs/assets/dbt-test-results.png)
![aggregate query results](docs/assets/aggregate-query-results.png)
```

## Portfolio Narrative

These assets should support the story that the project is not only a dashboard demo. It demonstrates:

- raw data to tested models
- explicit model grains
- enforced marts-layer contracts
- governed metrics
- additivity-aware aggregate design
- lineage-ready dbt documentation
