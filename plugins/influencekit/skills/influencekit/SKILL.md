---
name: influencekit
description: >-
  Use when orienting on InfluenceKit — what the platform and its MCP tools can
  do, the core concepts (tenant, campaign, deliverable, report, connection), and
  which routine fits a request. Read this when an InfluenceKit task is broad or
  ambiguous, or to pick among the campaign-recap, report-preflight,
  deliverable-repair, and connection-audit routines.
when_to_use: >-
  General InfluenceKit orientation and routing to the right routine. For a
  specific job, the dedicated routine (campaign-recap, report-preflight,
  deliverable-repair, connection-audit) will usually trigger on its own — this
  skill is the map, the concept reference, and the canonical 10-tool reference.
---

# InfluenceKit

You have access to the InfluenceKit MCP server — 10 read/ops tools for managing
influencer campaigns, tracking content performance, troubleshooting deliverables,
and preparing reports. This skill is the **orientation map**: what InfluenceKit
is, the tools you have, and which **routine** to reach for. It is not a dispatch
mechanism — each routine auto-loads on its own trigger.

> **Audience note.** `list_tenants` searches across accounts and the MCP requires
> an admin account, so these routines assume an **agency / account-manager /
> InfluenceKit-internal operator** working across tenants — not per-creator
> self-service.

## About InfluenceKit

InfluenceKit is an influencer marketing platform used by brands, agencies, and
influencers to:

- **Manage campaigns** — organize influencer partnerships with deliverables,
  deadlines, and performance goals.
- **Track content performance** — automatically pull stats (reach, impressions,
  engagement, clicks) from Instagram, TikTok, YouTube, Facebook, blogs, and more.
- **Generate reports** — build professional, shareable reports that showcase
  campaign results to clients and stakeholders.

### Key concepts

- **Tenant** — an InfluenceKit account (a brand, agency, or creator). Each tenant
  has users, social connections, and campaigns.
- **Campaign** — a marketing initiative containing one or more deliverables.
  Campaigns have statuses like active, completed, or draft.
- **Deliverable** — a specific piece of content (Instagram post, TikTok video,
  YouTube video, blog post, Instagram Story, etc.) that's part of a campaign.
  Deliverables track performance stats pulled from the social platform.
- **Report** — a curated collection of deliverables assembled for sharing with
  clients. Reports can include deliverables from one or multiple campaigns.
- **Social connection** — an OAuth link between InfluenceKit and a social
  platform. Connections need healthy tokens to pull stats.

## Ethics floor (every routine inlines this)

> *The creator's inbox and the client's trust are the commons.* Never fabricate
> or extrapolate a stat — every number traces to a tool call. Never present
> stale/errored stats as current without flagging. Never auto-send a report to a
> client. Flag missing data before sharing, don't hide it. If a fix needs the
> user to act in InfluenceKit, say so plainly.

Canonical copy: [`../ETHICS.md`](../ETHICS.md).

## The routines (index)

Four single-purpose routines. Each has a distinct trigger, inlines the ethics
floor, names the exact tools it uses, and declares any cap.

| Routine | Reach for it when | Tools |
|---------|-------------------|-------|
| **campaign-recap** | "How is campaign X doing / which content won?" | `list_campaigns`, `get_campaign`, `get_deliverable` |
| **report-preflight** | "Is this report client-ready before I send it?" | `get_report`, `diagnose_deliverable`, `check_connection` |
| **deliverable-repair** | "This one post has no stats / fix this deliverable." | `diagnose_deliverable`, `check_connection`, `clear_deliverable_error`, `refresh_deliverable`, `get_deliverable` |
| **connection-audit** | "Are all our social accounts healthy?" (account-wide) | `get_tenant`, `check_connection` |

Distinct surfaces: recap = performance, preflight = report QA, repair = one
broken item, audit = account-wide connection health. If a request spans two,
pick by the user's primary intent; don't run all four.

## The 10 tools (reference)

### Looking up accounts

- **list_tenants** — Search for and list InfluenceKit accounts. Use this to find
  a specific account by name or browse accounts. Returns account names, IDs, and
  basic info.
- **get_tenant** — Get full details for a specific account, including its users,
  social connections, subscription plan, and account settings. Use this when you
  need a complete picture of an account's setup.

### Working with campaigns

- **list_campaigns** — List campaigns, optionally filtered by status (active,
  completed, draft, etc.). Use this to see what campaigns are running, find a
  specific campaign, or get an overview of campaign activity.
- **get_campaign** — Get detailed information about a specific campaign,
  including its deliverables summary, date range, and performance overview.

### Checking deliverable performance

- **get_deliverable** — Get full details for a specific deliverable, including
  its current stats (reach, impressions, engagement, clicks), content type,
  platform, URL, and status.

### Reports

- **get_report** — Get a report's details along with its included deliverables
  and their stats. Use this to review what's in a report before it's shared, or
  to summarize report results.

### Troubleshooting

- **check_connection** — Check whether a social connection's OAuth token is
  healthy and able to pull data. Use this when stats aren't updating — a broken
  connection is the most common cause.
- **diagnose_deliverable** — Run a diagnostic check on a deliverable that's
  showing errors or missing stats. Returns a plain-language explanation of what's
  wrong and specific steps to fix it. This is your go-to tool when something
  isn't working with a deliverable.

### Fixing issues

- **refresh_deliverable** — Tell InfluenceKit to re-fetch stats from the social
  platform for a specific deliverable. Use this after fixing an underlying issue
  (like reconnecting an expired token) to pull fresh data.
- **clear_deliverable_error** — Clear the error state on a deliverable so it can
  be retried. Use this when a deliverable is stuck in an error state and you want
  to give it a fresh start before refreshing.

## What these tools do NOT do

This MCP is **read + ops only**. There is no creator discovery, no media-kit
read/write, and **no report or content creation** — you can read and prepare a
report, never create or send one. Requests for those surfaces are on the roadmap,
not in the toolset: see [`docs/mcp-routines-roadmap.md`](../../../../docs/mcp-routines-roadmap.md).
Don't promise a capability the 10 tools don't have.
