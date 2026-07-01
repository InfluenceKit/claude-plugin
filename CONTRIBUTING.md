# Contributing to the InfluenceKit routines

## The boundary (source-of-truth rule)

There are two layers here, and they must **not** duplicate each other:

- **The InfluenceKit MCP server** (the rails app) owns **capability and domain
  knowledge** — the single source of truth:
  - **tools** — what you can do / read (`get_campaign`, `create_report`, `influencer_discovery`, …)
  - **knowledge resources** — `data-model`, `report-metrics`, `industry-benchmarks`, `campaign-lifecycle`, `report-sharing`, `billing-usage`
  - **craft resources** — `metric-interpretation`, `error-handling`, `report-building`, `campaign-setup`
  - **prompts** — `campaign_report`, `diagnose_issues`, `account_health`, `discover_creators`

- **These skills** (the plugin) own only **workflow, judgment, and ethics** — the
  step-by-step of a task, which tools to call in what order, what to refuse, and
  how to present the result, for Claude specifically.

When a skill needs a definition, a benchmark, a data-model detail, or "what good
looks like," it **references the relevant MCP resource** (e.g. "read the
`report-metrics` resource") — it does **not** restate that knowledge inline.
Restating it is exactly how the plugin and server drift apart (that drift is what
once left the plugin documenting 10 tools while the server exposed 32).

## Checklist for a new or edited skill

- [ ] Frontmatter `name` / `description` / `when_to_use`, each **distinct** from other skills (routing is by description; overlap causes mis-fires).
- [ ] Declares its **role** (brand / influencer / any) and only calls tools available to that role.
- [ ] References **only real MCP tools** — run `scripts/check_tool_allowlist.rb`.
- [ ] Inlines the **ethics floor**; never auto-sends/auto-shares a report; never fabricates or extrapolates a stat.
- [ ] For any domain fact, benchmark, or metric interpretation: **points at the MCP resource**, never restates it.
- [ ] **Complements** the server prompts (e.g. references `campaign_report`) rather than re-implementing them.
- [ ] Worked example uses clearly-labeled placeholder numbers; declares any cap (no silent truncation).

## Why keep the knowledge on the server?

Tools are atomic; server prompts are user-invoked starters. Skills are the
auto-loading, Claude-specific "do this multi-step workflow well, with these
guardrails" layer. Keep the **knowledge** on the server (one source of truth,
shared by every MCP client); keep the **workflow** here.
