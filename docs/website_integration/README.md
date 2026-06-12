# Personal Website Integration

This folder contains the prepared website integration for adding the dbt portfolio project to `archive-of-li-li`.

The local website directory is expected at:

```text
/Users/apple/Documents/mywebsite/archive-of-li-li
```

Because the current Codex workspace cannot write outside `/Users/apple/Documents/DBT_data_product`, the integration is packaged here as a reproducible script.

Run from the DBT project root:

```bash
node docs/website_integration/apply_dbt_case_to_website.mjs
```

Then verify the personal website:

```bash
cd /Users/apple/Documents/mywebsite/archive-of-li-li
npm run build
```

Expected result:

- A new `DW-08` card appears under the `Data Work` section.
- The card title is `Trusted E-commerce Metrics with dbt`.
- The visual asset is added at `public/images/professional/trusted-ecommerce-metrics.svg`.
