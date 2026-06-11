# Resume Bullets

## English Version

**Analytics Engineering Portfolio: Trusted E-commerce Metrics with dbt and DuckDB**

- Built a reproducible dbt analytics engineering project that transforms synthetic GA4-like e-commerce events into tested staging, intermediate, and marts layers using DuckDB.
- Modeled Kimball-style marts including `dim_users`, `dim_products`, `fact_orders`, and `fact_sessions`, with explicit grains and a 30-minute inactivity-based sessionization workflow.
- Built an order-to-session attribution bridge to align revenue-by-channel metrics with recomputed converting sessions while preserving the original order-level source for auditability.
- Defined a governed metrics layer for 8 core e-commerce metrics, including GMV, orders, active users, conversion rate, AOV, repeat purchase rate, new vs returning users, and revenue by channel.
- Designed an additivity-safe aggregate table that stores numerator and denominator components instead of precomputed ratios, preventing incorrect BI rollups.
- Enforced marts-layer dbt data contracts and implemented 157 passing tests covering primary keys, foreign keys, accepted values, attribution coverage, business rules, and fact-to-aggregate reconciliation.
- Documented BigQuery/GA4 migration considerations, dbt lineage, metric definitions, and data contract decisions for portfolio review and interview discussion.

## Short English Version

- Built a dbt + DuckDB analytics engineering portfolio project transforming raw e-commerce events into contracted facts, dimensions, and governed metric components.
- Implemented dimensional modeling, sessionization, attribution consistency, data contracts, metric definitions, and 157 passing dbt tests for self-service analytics readiness.

## Chinese Version

**分析工程作品集：基于 dbt + DuckDB 的电商可信指标体系**

- 使用 dbt 与 DuckDB 构建可复现的分析工程项目，将 GA4-like 电商事件和交易数据建模为 staging、intermediate、marts 三层数仓结构。
- 基于 Kimball 思路设计 `dim_users`、`dim_products`、`fact_orders`、`fact_sessions`，并实现 30 分钟 inactivity sessionization。
- 建立 order-to-session attribution bridge，使按渠道收入尽量与转化 session 口径对齐，同时保留原始订单渠道用于审计。
- 定义 GMV、订单数、活跃用户、转化率、AOV、复购率、新老用户、按渠道收入等 8 个核心电商指标。
- 设计可加性安全的聚合表，只存储分子和分母组件，避免在 BI 层错误平均转化率、AOV 等 ratio 指标。
- 为 marts 层落地 dbt data contracts，并实现 157 个通过的 dbt tests，覆盖主键、外键、枚举值、归因覆盖、业务规则和事实表对账。
- 编写 BigQuery/GA4 迁移说明、指标定义、数据契约、lineage 和 case study，用于 GitHub 作品集与面试讲解。
