# dbt Lineage

This page provides a GitHub-renderable lineage view for the project. The generated dbt docs site also contains an interactive lineage graph after running `dbt docs generate`.

```mermaid
flowchart LR
    subgraph raw["Raw Seeds"]
        raw_events["raw_events"]
        raw_orders["raw_orders"]
        raw_order_items["raw_order_items"]
        raw_products["raw_products"]
        raw_users["raw_users"]
    end

    subgraph staging["Staging Layer"]
        stg_events["stg_events"]
        stg_orders["stg_orders"]
        stg_order_items["stg_order_items"]
        stg_products["stg_products"]
        stg_users["stg_users"]
    end

    subgraph intermediate["Intermediate Layer"]
        int_user_sessions["int_user_sessions"]
        int_order_items_enriched["int_order_items_enriched"]
        int_order_session_attribution["int_order_session_attribution"]
    end

    subgraph marts["Marts Layer"]
        dim_users["dim_users"]
        dim_products["dim_products"]
        fact_orders["fact_orders"]
        fact_sessions["fact_sessions"]
        agg_daily_ecommerce_metrics["agg_daily_ecommerce_metrics"]
    end

    raw_events --> stg_events
    raw_orders --> stg_orders
    raw_order_items --> stg_order_items
    raw_products --> stg_products
    raw_users --> stg_users

    stg_events --> int_user_sessions
    stg_events --> int_order_session_attribution
    stg_orders --> int_order_session_attribution
    int_user_sessions --> int_order_session_attribution

    stg_orders --> int_order_items_enriched
    stg_order_items --> int_order_items_enriched
    stg_products --> int_order_items_enriched

    stg_users --> dim_users
    stg_orders --> dim_users
    int_user_sessions --> dim_users

    stg_products --> dim_products
    int_order_items_enriched --> dim_products

    stg_orders --> fact_orders
    int_order_items_enriched --> fact_orders
    int_order_session_attribution --> fact_orders

    int_user_sessions --> fact_sessions

    fact_sessions --> agg_daily_ecommerce_metrics
    dim_users --> agg_daily_ecommerce_metrics
    fact_orders --> agg_daily_ecommerce_metrics
```

## How to Read This Graph

- Raw seeds simulate GA4-like e-commerce events and transaction data.
- Staging models standardize field names, types, and source-specific cleanup.
- Intermediate models hold reusable transformations such as 30-minute sessionization, enriched order items, and order-to-session attribution.
- Marts expose contracted facts, dimensions, and additive metric components.
- `agg_daily_ecommerce_metrics` is intentionally downstream of facts and dimensions so metric components reconcile back to trusted marts.
