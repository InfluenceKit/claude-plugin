# InfluenceKit Routines — MCP Gap Roadmap

**Status:** revised against the **real** MCP (June 2026). The earlier draft of this
file was written against a stale, 10-tool, admin-only picture of the MCP and
listed report creation, discovery, and manual stats as "not built." They **are**
built. This revision demotes what shipped and re-points the backlog at what is
genuinely still open.

The routines in `plugins/influencekit/skills/` are grounded strictly in the **33
shipped tools** registered in `app/mcp/influencekit_mcp_server.rb` (the `TOOLS`
array). The tool-allowlist check (`scripts/check_tool_allowlist.rb`) enforces that
no `SKILL.md` names a tool outside that set — this is the guard that the old
`list_tenants` phantom slipped past. **Names that appear only here in the roadmap
(future tools) must never be referenced from a `SKILL.md`.**

---

## What already shipped (demoted from the backlog)

These were on the old roadmap as gaps. They exist today; the routines use them.

| Capability | Real tool(s) | Notes |
|---|---|---|
| Create a report | `create_report` (event-backed), `create_builder_report` (filter-based) | `create_report` is **influencer-only** and returns `event_id` + `share_url` in one step. |
| Add content to a report | `add_deliverable` | URLs (+ note) onto an event; partner-can-add covers cross-tenant. |
| Manual / off-platform stats, label, type override | `update_deliverable` | Manual `reach`→`impressions_unique`, `impressions`; `title`; `provider` (e.g. `beehiiv`). This is the **newsletter** path today. |
| Creator discovery | `influencer_discovery` | Brand-only; niche/platform/location/followers/engagement filters. |
| AI brand visibility | `ai_search_status` / `ai_search_results` / `ai_search_queries` / `ai_search_run_check` | "AI Search" — LLM mention tracking, brand-only. |
| List/search reports | `list_reports`, `query_report_data` | Any age, name search, pagination; composite read. |
| Delete a report / event | `delete_report`, `delete_event` | Destructive; owner-scoped. |
| Composite reads | `query_report_data`, `query_campaign_data` | Reports/campaigns + deliverables + metrics in one call. |

The `report-builder` and `creator-discovery` routines exist **because** these
shipped — they were the headline "v2" items on the old roadmap.

---

## Genuinely open (elevate)

Evidence for these is real agent-run usage (the Bethany / Kidding Around Media
report-building transcripts), where the workaround is manual and visible.

### 1. Report **date-sort** toggle
- **Gap:** no way to flip a report's deliverable ordering (e.g. newest-first vs
  campaign order) via the MCP. Agents can't honor "sort these by date."
- **Shape:** a sort option on `create_report` / a report-update tool, or a
  `sort:` field on the report's sections.
- **Why now:** comes up every time a multi-deliverable report is assembled.

### 2. **Group-by-tag / client-facing label per deliverable** (packages)
- **Gap:** `update_deliverable` sets a per-card `title`, but there's no grouping —
  no "Package A / Package B" sectioning or per-group subtotals in a report.
- **Shape:** a deliverable `group`/`section` attribute + report grouping, or a
  builder filter that emits grouped output.
- **Why now:** agencies present deliverables in client-facing packages; today
  that's faked with title prefixes.

### 3. **CSV export** from a shareable report
- **Gap:** the share view is HTML only; no MCP tool returns a report's rows as CSV.
- **Shape:** `export_report(report_id, format: "csv")` returning a download/URL.
- **Why now:** clients ask for the raw numbers; agents currently can't hand them over.

### 4. **Newsletter auto-pull**
- **Gap:** newsletter reach/impressions are entered **manually** via
  `update_deliverable`. There's no provider integration that pulls beehiiv /
  Mailchimp / ConvertKit stats automatically.
- **Shape:** newsletter-provider connectors feeding `Statistic`s like the social
  platforms do, so `refresh_deliverable` works for newsletters too.
- **Why now:** manual entry is the single biggest hand-edit in the report-builder
  flow, and it's the one most prone to a fabricated number if an agent isn't
  careful (the ethics floor leans on this staying explicit until it's automated).

### 5. **Non-MCP plain-HTTP option** (API-key header)
- **Gap:** the server is MCP-only (JSON-RPC over Streamable HTTP + OAuth). Runners
  that aren't MCP clients (e.g. Hyperagent and other plain-HTTP agent platforms)
  can't call it — "the server is up" but their runner isn't an MCP client.
- **Shape:** a thin REST surface over the same tools, authenticated by an
  `Authorization`/API-key header, scoped to one tenant.
- **Why now:** it's the difference between "works in Claude" and "works in any
  agent a customer already runs." Pairs with item 6.

### 6. **Tenant-scoped public auth** (self-service)
- **Gap:** today's auth resolves a tenant from a logged-in user (and super-admins
  can cross tenants). There's no first-class, tenant-scoped credential a customer
  can mint for *their own* account.
- **Shape:** per-tenant API credentials / OAuth client scoped to one tenant, so
  the routines can go public per-creator instead of operator-mediated.
- **Why now:** prerequisite for shipping these routines as a self-service product
  surface rather than an internal/agency tool. Gates items 3–5 going public.

---

## Open architecture question (flag — do not decide here)

**Should the client routines live in this repo at all?**

There is real duplication risk. The MCP server already exposes server-side domain
knowledge and craft guidance as **resources** (`app/prompts/brand_assistant/`:
`skills/_data_model.txt`, `_campaign_lifecycle`, `_report_metrics`,
`_industry_benchmarks`, `_report_sharing`, `_billing_usage`; `craft/`:
`_metric_interpretation`, `_error_handling`, `_report_building`, `_campaign_setup`)
and four server-side **prompts** (`campaign_report`, `diagnose_issues`,
`account_health`, `discover_creators`).

The routines here deliberately **reference** those rather than restate them — but
the boundary is fuzzy and will drift. Options to weigh (not resolve in this PR):

- **Keep here, reference-only.** Routines stay thin client-side orchestration;
  domain truth stays server-side. Risk: two repos, manual sync, drift in tool
  names/roles (exactly what this revision had to fix).
- **Generate from the server.** Derive routines (or at least the tool/role/param
  reference) from `influencekit_mcp_server.rb` + `app/prompts/brand_assistant/` so
  the allowlist and role map can't go stale. Risk: build tooling, less hand-tuned
  prose.
- **Move server-side.** Express these as additional MCP prompts in the Rails app,
  dropping the separate plugin. Risk: loses the Claude Code plugin/marketplace
  distribution and the per-routine auto-load triggers.

Decision owner: Bruno. This file just flags it so the next revision doesn't
silently re-introduce the drift.

---

## Guardrails that carry forward

The ethics floor is not v1-specific — it scales with the write-side tools, where
the stakes are higher:

- `report-builder` already **creates** reports — it must still **never auto-send
  or auto-share**. Returning a `share_url` is not sending it.
- Manual stats (`update_deliverable` reach/impressions) must come from the user or
  source, entered verbatim — never estimated. Newsletter auto-pull (item 4) is
  what finally removes the temptation.
- Every discovery/AI-Search number must trace to a tool call; "provider
  unavailable this run" is never the same as "brand not mentioned."
- Any future `outreach`/messaging tool holds an explicit anti-spam gate — drafts
  for human review, not auto-sends — the same posture the report routines take.
