# v2 Design Review

## Problem: Channel Revenue and Session Conversion Can Drift

In v1, session metrics used the recomputed session traffic source, while order metrics used the order-level traffic source. That is a reasonable first implementation, but it can create marketing reporting drift: a channel can appear to drive conversion sessions while revenue is grouped under a different order source.

## Change

v2 adds `int_order_session_attribution`, an intermediate bridge with one row per order. The bridge links each order to a recomputed converting session when possible and exposes:

- `attribution_method`: `purchase_event_match`, `timestamp_window_match`, or `order_source_fallback`
- `attribution_status`: `attributed` or `fallback`
- `attributed_traffic_source`: the source used for revenue-by-channel reporting

`fact_orders` keeps the original `traffic_source` as the order-level source and adds the attribution fields. `agg_daily_ecommerce_metrics` now aggregates order metrics by `attributed_traffic_source`, while session metrics continue to use session source.

## Why It Matters

This makes the project closer to a real analytics engineering system. Marketing and growth teams need conversion and revenue metrics to use compatible attribution assumptions; otherwise dashboards can disagree even when every SQL query is technically correct.

The design also separates method from status:

- Method explains how the source was assigned.
- Status explains whether the order was linked to a recomputed session or only fell back to the order-level source.

## Remaining Limitations

This portfolio version uses deterministic seed data and a converting-session attribution bridge. In production, the next design choices would include:

- late-arriving event lookback windows
- source `ga_session_id` or other first-party session identifiers
- last non-direct touch, time-decay, position-based, or other multi-touch attribution rules
- order status event facts for cancellations, returns, and negative revenue adjustments
- CI/CD gates that run contract and reconciliation tests before production deployment
