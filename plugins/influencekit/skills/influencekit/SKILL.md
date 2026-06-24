---
name: influencekit
description: >-
  Use when an InfluenceKit request is broad, ambiguous, or you need to orient on
  what the MCP can do — the role model (brand vs influencer vs all), the real
  tool/prompt/resource surface, and which routine fits. Triggers on "what can
  InfluenceKit do", "connect to my InfluenceKit account", or any InfluenceKit
  task that doesn't obviously map to one routine.
when_to_use: >-
  InfluenceKit orientation and routing. For a specific job the dedicated routine
  (report-builder, report-preflight, deliverable-repair, connection-audit,
  campaign-recap, creator-discovery, mcp-setup) usually triggers on its own —
  this skill is the map: the role model, the real tool reference, and the
  pointers to the MCP's own prompts and knowledge resources.
---

# InfluenceKit

You are connected to the **InfluenceKit MCP server** (`https://api.influencekit.com/mcp`)
— a **role-aware** toolset for influencer-marketing work: campaigns, content
performance, deliverable troubleshooting, and shareable reports. This skill is
the **orientation map** — the role model, which routine to reach for, and the
real tool surface. It is not a dispatcher; each routine auto-loads on its own
trigger.

## The MCP tells you who you are — don't re-derive it

The connection is **session-scoped to one tenant**, resolved from the logged-in
user. There is **no `list_tenants` and no cross-account browsing** — a token sees
exactly one account. (Only an InfluenceKit super-admin connection may target
another tenant, by passing `tenant_id`/`tenant_subdomain`; ordinary users never
do.) So: **don't ask for or invent a tenant id** — just call the tools.

**Read the MCP's own context first, instead of guessing or re-explaining it:**

- **`session_context` resource** — account name, type, plan/quota, active
  campaigns, connected platforms, and current error counts. Read it at the start
  of any non-trivial task; it usually saves several tool calls.
- **Knowledge resources** — `data-model`, `campaign-lifecycle`, `report-metrics`,
  `industry-benchmarks`, `report-sharing`, `billing-usage`. These are the
  **authoritative** domain reference. Don't paraphrase the data model from
  memory; read the resource.
- **Craft resources** — `metric-interpretation`, `error-handling`,
  `report-building`, `campaign-setup`. How to interpret and present, not just
  what the fields are.
- **Server prompts** — `campaign_report`, `diagnose_issues`, `account_health`,
  `discover_creators`. These are first-class workflows the server ships; the
  routines here **complement** them (a recap routine references `campaign_report`
  rather than re-implementing it).

## Roles: brand vs influencer

InfluenceKit is two-sided, and most tools are gated by account type. Know which
side you're on (it's in `session_context.account_type` / `get_tenant`).

- **Brand / agency** accounts own **campaigns** (`PartnerCampaign`), define
  **assignments** (work items), **invite** influencers, discover creators, and
  track AI Search (LLM brand visibility).
- **Influencer / creator** accounts own **events** (their content calendar),
  attach **deliverables**, and build **event-backed reports** they share with
  clients.
- **Both** can read campaigns/reports/deliverables, diagnose and repair
  deliverables, check connections, resolve URLs, and navigate.

A tool called against the wrong role returns a plain `error` (e.g. "only
available for brand accounts") — the routines route by role so you don't hit
that.

## Ethics floor (every routine inlines this)

> *The creator's inbox and the client's trust are the commons.* Never fabricate
> or extrapolate a stat — every number traces to a tool call. Never present
> stale/errored stats as current without flagging. Never auto-send or auto-share
> a report — preparing or creating a report is not sending it; the human sends.
> Flag missing data before sharing, don't hide it. If a fix needs the user to act
> in InfluenceKit (reconnect, fix a URL, log in), say so plainly.

Canonical copy: [`../ETHICS.md`](../ETHICS.md).

## The routines (index)

Seven single-purpose routines. Each has a distinct trigger, declares its **role**,
inlines the ethics floor, names the exact tools it uses, and declares any cap.

| Routine | Role | Reach for it when | Key tools |
|---------|------|-------------------|-----------|
| **report-builder** | influencer | "Build/assemble a shareable report from these URLs." | `create_report`, `add_deliverable`, `update_deliverable` |
| **report-preflight** | any | "Is this report client-ready before I send it?" | `query_report_data`, `get_report`, `diagnose_deliverable`, `check_connection` |
| **deliverable-repair** | any | "This one post has no stats / fix this deliverable." | `diagnose_deliverable`, `check_connection`, `clear_deliverable_error`, `refresh_deliverable`, `update_deliverable`, `get_deliverable` |
| **connection-audit** | any | "Are all our social accounts healthy?" (account-wide) | `get_tenant`, `check_connection` |
| **campaign-recap** | brand & influencer (split) | "How is campaign X doing / which content won?" | `query_campaign_data`, `list_campaigns`, `get_campaign`, `my_deliverables`, `query_report_data` |
| **creator-discovery** | brand | "Find creators in <niche>; are we showing up in AI answers?" | `influencer_discovery`, `ai_search_status`, `ai_search_results`, `ai_search_queries`, `ai_search_run_check` |
| **mcp-setup** | any (onboarding) | "I can't connect / I'm getting 401 / the connector won't add." | (setup; smoke-tests with `get_tenant`, `check_connection`) |

Distinct surfaces: builder = create, preflight = report QA, repair = one broken
item, audit = account-wide connections, recap = performance, discovery = find
creators + AI visibility, setup = getting connected. If a request spans two, pick
by the user's primary intent; don't run several.

## Real tool reference (33 tools, role-aware)

Names are verbatim. `read` = read-only; `write` = creates/changes/ops. Tenant is
implicit (session-scoped); only super-admins pass `tenant_id`/`tenant_subdomain`.

### Read — any role
- **get_tenant** — account details: users, connections, plan, counts.
- **list_campaigns** — a brand's campaigns (active/archived).
- **get_campaign** — one campaign with its assignments + per-influencer invitations.
- **get_deliverable** — one deliverable: stats, error, connection, (YouTube) channel.
- **list_reports** — reports for the account (name search, paginate; any age).
- **get_report** — one report with deliverables and the public **share_url**.
- **query_report_data** — composite: reports + deliverables + aggregate metrics in one call.
- **query_campaign_data** — composite: campaigns + assignments + invitations + metrics in one call.
- **check_connection** — one OAuth token's health (`token_id`).
- **diagnose_deliverable** — why a deliverable is failing + a `next_step` hint.

### Brand-only
- **account_status** — activation checklist / setup progress.
- **influencer_discovery** — search creators by name/handle/niche/platform/location/followers/engagement.
- **campaign_create** — create a campaign (`name`).
- **brand_profile_get** / **brand_profile_update** — read/patch the brand profile (read before update).
- **ai_search_status** — latest AI Search (LLM brand-visibility) check: mention rate + per-provider breakdown.
- **ai_search_results** — per-query AI Search results for a check.
- **ai_search_queries** — list active AI Search queries, or add one.
- **ai_search_run_check** — enqueue a new AI Search check.

### Influencer-only
- **my_deliverables** — your deliverables with status/errors (filter by event/error).
- **create_event** — create an event (content campaign) on your calendar.
- **add_deliverable** — add deliverable URLs (+ optional note) to an event.
- **delete_event** — delete an owned event (also deletes its deliverables + report). Destructive.
- **create_report** — create/fetch the **event-backed** report (name → event + share_url in one step).

### Write / ops — any role
- **assignments** — manage `Assignment` work items (`list`/`get`/`create`; create is brand-only).
- **invitations** — manage per-influencer `TenantAssignment`s (`list`/`get`/`invite`/`signup_link`; invite is brand-only).
- **update_deliverable** — override title/description/provider, or set manual reach/impressions.
- **create_builder_report** — create a free-form **filter-based** report (not tied to one event).
- **delete_report** — delete an owned report (keeps the event/deliverables). Destructive.
- **refresh_deliverable** — re-fetch stats from the platform API.
- **clear_deliverable_error** — clear a deliverable's error state for retry.
- **navigation** — map a user goal to an in-app URL path.
- **resolve_url** — turn a pasted InfluenceKit URL into a resource type + numeric id.

## Notes

- **`create_report` is influencer-only and event-backed** (a report is the report
  *of* an event). Brands report on campaigns/assignments — use `query_campaign_data`
  and the `assignments`/`invitations` tools, not `create_report`.
- **No `list_tenants`.** Any older orientation/assistant content that lists a 10-tool,
  admin-scoped, cross-tenant toolset (with `list_tenants` and "no report creation")
  is **obsolete** — it predates this role-aware, write-capable MCP.
- Pasting a browser URL? Use **resolve_url** to get the id, then call the typed tool.
