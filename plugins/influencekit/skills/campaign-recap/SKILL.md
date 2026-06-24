---
name: campaign-recap
description: >-
  Use when summarizing how a campaign or a creator's content performed — total
  reach, impressions, engagement rate, top deliverables, platform breakdown — for
  one or more campaigns/events. Triggers on "how is campaign X doing", "which
  posts did best", "recap our summer campaign", "how did my content do this month".
when_to_use: >-
  Performance recaps and "which deliverable won" questions, for either side
  (brands recap campaigns/assignments; influencers recap their events/
  deliverables). NOT for checking a report before sending (use report-preflight),
  NOT for building a report (use report-builder), NOT for fixing one broken
  deliverable (use deliverable-repair), NOT for account-wide connection health
  (use connection-audit).
---

# Campaign Recap

**Role: brand & influencer (the path splits).** Campaigns (`PartnerCampaign`) are
**brand-owned**; an influencer doesn't own campaigns — they own **events** and see
the campaigns they were *invited* to via assignments. Pick the path by account
type (`session_context.account_type` / `get_tenant`).

> **Server prompt note.** The MCP already ships a `campaign_report` prompt
> ("generate a campaign performance report, broken down by platform"). If the
> user wants the full guided report, prefer invoking that prompt. This routine is
> the **grounded recap discipline** — the caps, the no-fabrication floor, and the
> fixed output — for when you're assembling the numbers yourself.

## Overview

Produce a grounded recap: headline totals, deliverables **ranked by their actual
stats**, a platform breakdown, and a few insights drawn **only from the numbers**.
Every figure traces to a tool call — no estimates, no speculative "why it worked."

## When to use

- Brand: "How is our summer campaign doing?" / "Which posts performed best in Campaign X?"
- Influencer: "How did my content do this month?" / "Recap my September posts."

**When NOT to use:** report QA before sending (use `report-preflight`), building a
report (use `report-builder`), a single broken deliverable (use
`deliverable-repair`), or "are our accounts connected" (use `connection-audit`).

## Ethics floor (always applies)

> *The creator's inbox and the client's trust are the commons.*

- **Never fabricate or extrapolate a stat.** Every number traces to a tool call.
  If you don't have a number, say so — don't estimate, round up, or infer it.
- **Never present stale or errored stats as current** without flagging them.
- **Never auto-send a report to a client.** Preparing is not sending.
- **Flag missing data before sharing — don't hide it.**
- **If a fix needs the user to act in InfluenceKit**, say so plainly.

## Tools this routine uses

### Brand path (campaigns)
- **query_campaign_data** — The composite read: campaigns pre-joined with
  `assignments` (the work items), `invitations` (per-influencer signups),
  `deliverables`, and `metrics` in one call. Start here. Pass `campaign_id` or
  `search`; `include: "assignments,invitations,deliverables,metrics"`.
- **list_campaigns** — Enumerate campaigns (active/archived) when you need to find
  the one the user means.
- **get_campaign** — One campaign's assignments + invitations + deliverables
  summary, if you want the single-campaign view rather than the composite.

### Influencer path (events / own content)
- **my_deliverables** — Your deliverables with status, filtered by `event_id` or
  `has_error`. The entry point for "how did my content do."
- **query_report_data** — Composite read over your reports + deliverables +
  metrics (`include: "deliverables,metrics"`), for an event-/report-level recap.
- **get_report** — One report's deliverables and totals.

No writes. This routine never creates, refreshes, or sends anything.

## How to run it

1. **Pick the path by role.** Brand → campaigns; influencer → events/deliverables.
2. **Resolve the subject.** Brand: `list_campaigns`/`search` to get the
   `campaign_id` (or `resolve_url` on a pasted link). Influencer: identify the
   event or just pull recent `my_deliverables`.
3. **Pull the composite.** Brand: `query_campaign_data(campaign_id:,
   include: "assignments,invitations,deliverables,metrics")`. Influencer:
   `my_deliverables(...)` then `query_report_data(...)` for aggregates.
4. **Rank by an actual metric.** Default to reach/impressions; if a metric is
   missing for some items, state which metric you ranked on and why.
5. **Break down by platform** from the stats you pulled.
6. **Write 2–3 insights drawn only from the numbers.** "The two Reels out-reached
   the four static posts 3:1" is allowed. "Reels work better because the algorithm
   favors video" is **not** — that's speculation, not data.
7. **Flag any deliverable with missing or errored stats** instead of dropping it.

## Cap (no silent truncation)

If you fan out per-deliverable reads, **cap at the first 25 deliverables** and
state how many exist, how many you used, and how they were selected. (The
composite tools already cap their own returns — `query_campaign_data` and
`query_report_data` clamp to 25 results and sample deliverables; surface that
rather than implying you saw everything.) Never silently truncate.

## Output format (fixed)

```
# Recap: SUBJECT (date range)

## Headline
- Deliverables: n used of n total
- Total reach/impressions: sum
- Avg engagement rate: value (across deliverables with engagement data)

## Top deliverables (ranked by metric)
1. platform — content type — reach x, eng rate y — url
2. ...

## Platform breakdown
- Instagram: n deliverables, reach x
- TikTok: ...

## Insights (from the numbers only)
- insight 1
- insight 2

## Needs attention
- deliverable — missing stats / errored / stale (flagged, not dropped)
```

## Worked example

> **Illustrative only — every number is a placeholder.** Real figures come from
> `query_campaign_data` / `query_report_data`.

Brand user: *"How did our Spring Launch campaign do?"*

1. `list_campaigns(archived: false)` resolves "Spring Launch" to id `812`.
2. `query_campaign_data(campaign_id: 812, include: "deliverables,metrics")` →
   9 deliverables, ran Mar 1–Apr 15, metrics pre-aggregated.

```
# Recap: Spring Launch (Mar 1 – Apr 15)

## Headline
- Deliverables: 9 of 9
- Total impressions: 588,000
- Avg engagement rate: 4.1% (8 of 9 deliverables had engagement data)

## Top deliverables (ranked by reach)
1. Instagram — Reel — reach 96,000, eng rate 6.2% — instagram.com/p/...
2. TikTok — Video — reach 81,000, eng rate 5.0% — tiktok.com/@.../video/...
3. Instagram — Story — reach 44,000, eng rate 2.1% — (story)

## Platform breakdown
- Instagram: 5 deliverables, reach 248,000
- TikTok: 3 deliverables, reach 150,000
- YouTube: 1 deliverable, reach 14,000

## Insights (from the numbers only)
- The two Reels out-reached the four static Instagram posts roughly 3:1.
- TikTok carried the highest average engagement rate (5.0%) of any platform.

## Needs attention
- YouTube Short "behind the scenes" — stats errored, not included in totals (flagged).
```
