import fs from "node:fs";
import path from "node:path";

const websiteRoot =
  process.argv[2] || "/Users/apple/Documents/mywebsite/archive-of-li-li";

const dataPath = path.join(websiteRoot, "src/data/professionalCases.js");
const imageDir = path.join(websiteRoot, "public/images/professional");
const imagePath = path.join(imageDir, "trusted-ecommerce-metrics.svg");

const caseBlock = `  {
    id: "DW-08",
    title: "Trusted E-commerce Metrics with dbt",
    titleZh: "基于 dbt 的电商可信指标工程",
    category: "Analytics engineering portfolio",
    categoryZh: "分析工程作品集",
    problem:
      "E-commerce metrics can drift when marketing, product, and finance teams rebuild revenue, conversion, and attribution logic from raw event data.",
    problemZh:
      "当市场、产品和财务团队分别从原始事件数据里重建收入、转化和归因逻辑时，电商指标很容易出现口径漂移。",
    action:
      "Built a local-first dbt + DuckDB project that models raw orders and event data into staging, intermediate, fact, dimension, and daily metric models, with 30-minute sessionization and an order-to-session attribution bridge.",
    actionZh:
      "使用 dbt + DuckDB 构建 local-first 分析工程项目，将原始订单和事件数据建模为 staging、intermediate、fact、dimension 和每日指标模型，并实现 30 分钟 sessionization 与 order-to-session attribution bridge。",
    result:
      "Created a reproducible trusted-metrics foundation with dbt contracts, GitHub Actions CI, additive metric components, and 150+ dbt tests, with the latest v2 local run passing 158 tests.",
    resultZh:
      "沉淀可复现的可信指标层：包含 dbt contracts、GitHub Actions CI、可加性指标组件和 150+ dbt tests；最新 v2 本地验证通过 158 个 tests。",
    framework: [
      {
        label: "What",
        labelZh: "做什么",
        text: "A portfolio-scale analytics engineering project for trusted e-commerce metrics.",
        textZh: "面向电商可信指标的作品集级分析工程项目。",
      },
      {
        label: "Why",
        labelZh: "为什么",
        text: "Prevent metric drift before data reaches dashboards by defining grains, contracts, attribution logic, and additive components.",
        textZh: "在数据进入看板前，通过明确粒度、数据契约、归因逻辑和可加性组件，减少指标口径漂移。",
      },
      {
        label: "How",
        labelZh: "怎么做",
        text: "Used dbt layers, SQL window functions, attribution bridge logic, marts contracts, reconciliation tests, and CI.",
        textZh: "使用 dbt 分层、SQL 窗口函数、归因桥接逻辑、marts 数据契约、对账测试和 CI。",
      },
      {
        label: "Outcome",
        labelZh: "成果信号",
        text: "13 dbt models, 5 seed tables, one-click local run, GitHub Actions CI, and 150+ passing tests.",
        textZh: "13 个 dbt models、5 张 seed tables、一键本地运行、GitHub Actions CI 和 150+ passing tests。",
      },
    ],
    examples: [
      "Raw seeds -> staging -> intermediate -> marts -> trusted metric components",
      "30-minute inactivity sessionization",
      "Order-to-session attribution for revenue by channel",
      "Additive components for conversion rate, AOV, repeat purchase rate, and revenue by channel",
    ],
    examplesZh: [
      "Raw seeds -> staging -> intermediate -> marts -> trusted metric components",
      "30 分钟 inactivity sessionization",
      "用于按渠道收入的 order-to-session attribution",
      "转化率、AOV、复购率和渠道收入的可加性指标组件",
    ],
    skills: ["dbt", "DuckDB", "SQL", "Analytics engineering", "Data contracts", "Metric governance", "CI"],
    skillsZh: ["dbt", "DuckDB", "SQL", "分析工程", "数据契约", "指标治理", "CI"],
    image: "/images/professional/trusted-ecommerce-metrics.svg",
    imageAlt: "Trusted e-commerce metrics diagram showing raw data, dbt layers, attribution, contracts, tests, and portfolio evidence",
  },`;

const svg = `<svg width="960" height="640" viewBox="0 0 960 640" fill="none" xmlns="http://www.w3.org/2000/svg" role="img" aria-labelledby="title desc">
  <title id="title">Trusted E-commerce Metrics with dbt</title>
  <desc id="desc">Architecture diagram showing raw orders and events flowing through dbt staging, intermediate, marts, metric components, tests, and CI.</desc>
  <rect width="960" height="640" rx="32" fill="#F8F4EC"/>
  <rect x="54" y="52" width="852" height="536" rx="28" fill="#FFFDF8" stroke="#2F3A35" stroke-width="3"/>
  <text x="88" y="108" fill="#2F3A35" font-family="Inter, Arial, sans-serif" font-size="34" font-weight="700">Trusted E-commerce Metrics</text>
  <text x="88" y="143" fill="#6B5E52" font-family="Inter, Arial, sans-serif" font-size="18">dbt + DuckDB portfolio-scale analytics engineering</text>
  <g font-family="Inter, Arial, sans-serif" font-size="16" font-weight="700">
    <rect x="88" y="210" width="152" height="72" rx="16" fill="#E8EFE7" stroke="#496557" stroke-width="2"/>
    <text x="121" y="240" fill="#2F3A35">Raw seeds</text>
    <text x="113" y="265" fill="#6B5E52" font-size="13" font-weight="500">orders + events</text>
    <rect x="294" y="210" width="152" height="72" rx="16" fill="#E9EDF7" stroke="#4F5F89" stroke-width="2"/>
    <text x="331" y="240" fill="#2F3A35">Staging</text>
    <text x="324" y="265" fill="#6B5E52" font-size="13" font-weight="500">clean + type</text>
    <rect x="500" y="210" width="174" height="72" rx="16" fill="#F6E8DE" stroke="#9A6048" stroke-width="2"/>
    <text x="537" y="240" fill="#2F3A35">Intermediate</text>
    <text x="529" y="265" fill="#6B5E52" font-size="13" font-weight="500">sessions + attribution</text>
    <rect x="728" y="210" width="144" height="72" rx="16" fill="#F4EACF" stroke="#8A6B2E" stroke-width="2"/>
    <text x="768" y="240" fill="#2F3A35">Marts</text>
    <text x="755" y="265" fill="#6B5E52" font-size="13" font-weight="500">facts + dims</text>
  </g>
  <g stroke="#2F3A35" stroke-width="3" stroke-linecap="round"><path d="M246 246H286"/><path d="M452 246H492"/><path d="M680 246H720"/></g>
  <g fill="#2F3A35"><path d="M286 246L275 239V253L286 246Z"/><path d="M492 246L481 239V253L492 246Z"/><path d="M720 246L709 239V253L720 246Z"/></g>
  <rect x="118" y="354" width="228" height="96" rx="18" fill="#2F3A35"/>
  <text x="146" y="390" fill="#FFFDF8" font-family="Inter, Arial, sans-serif" font-size="20" font-weight="700">30-min sessions</text>
  <text x="146" y="419" fill="#D9E6D6" font-family="Inter, Arial, sans-serif" font-size="14">Window functions split events</text>
  <rect x="366" y="354" width="228" height="96" rx="18" fill="#803F2C"/>
  <text x="394" y="390" fill="#FFFDF8" font-family="Inter, Arial, sans-serif" font-size="20" font-weight="700">Attribution bridge</text>
  <text x="394" y="419" fill="#F9DCD0" font-family="Inter, Arial, sans-serif" font-size="14">Orders linked to sessions</text>
  <rect x="614" y="354" width="228" height="96" rx="18" fill="#40537D"/>
  <text x="642" y="390" fill="#FFFDF8" font-family="Inter, Arial, sans-serif" font-size="20" font-weight="700">Metric components</text>
  <text x="642" y="419" fill="#DCE4FA" font-family="Inter, Arial, sans-serif" font-size="14">No precomputed ratios</text>
  <g font-family="Inter, Arial, sans-serif" font-size="14" font-weight="700">
    <rect x="136" y="498" width="154" height="50" rx="25" fill="#E8EFE7" stroke="#496557" stroke-width="2"/>
    <text x="170" y="529" fill="#2F3A35">150+ tests</text>
    <rect x="326" y="498" width="154" height="50" rx="25" fill="#F6E8DE" stroke="#9A6048" stroke-width="2"/>
    <text x="361" y="529" fill="#2F3A35">Contracts</text>
    <rect x="516" y="498" width="154" height="50" rx="25" fill="#E9EDF7" stroke="#4F5F89" stroke-width="2"/>
    <text x="559" y="529" fill="#2F3A35">CI gate</text>
    <rect x="706" y="498" width="154" height="50" rx="25" fill="#F4EACF" stroke="#8A6B2E" stroke-width="2"/>
    <text x="740" y="529" fill="#2F3A35">Lineage</text>
  </g>
</svg>
`;

if (!fs.existsSync(dataPath)) {
  throw new Error(`Cannot find website data file: ${dataPath}`);
}

let source = fs.readFileSync(dataPath, "utf8");

if (!source.includes('id: "DW-08"')) {
  const trimmed = source.trimEnd();
  if (!trimmed.endsWith("];")) {
    throw new Error("Unexpected professionalCases.js ending");
  }
  source = `${trimmed.slice(0, -2).trimEnd()}\n${caseBlock}\n];\n`;
  fs.writeFileSync(dataPath, source);
  console.log("Inserted DW-08 into src/data/professionalCases.js");
} else {
  console.log("DW-08 already exists; data file unchanged");
}

fs.mkdirSync(imageDir, { recursive: true });
fs.writeFileSync(imagePath, svg);
console.log(`Wrote ${imagePath}`);
