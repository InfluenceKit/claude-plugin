---
name: campaign-recap
description: >-
  Use when summarizing how a campaign performed or ranking which content won —
  total reach, impressions, engagement rate, top deliverables, and platform
  breakdown — for one or more named campaigns. Triggers on "how is campaign X
  doing", "which posts did best", "recap our summer campaign".
when_to_use: >-
  Campaign-level performance recaps and "which deliverable won" questions. NOT
  for checking a report before sending it to a client (use report-preflight),
  NOT for fixing one broken deliverable (use deliverable-repair), NOT for
  account-wide connection health (use connection-audit).
---

# Campaign Recap

## Overview

Produce a grounded recap of a campaign's performance: headline totals,
deliverables **ranked by their actual stats**, a platform breakdown, and a few
insights drawn **only from the numbers**. Every figure traces to a tool call —
no estimates, no speculative "why it worked."

## When to use

- "How is our summer campaign doing?"
- "Which posts performed best in Campaign X?"
- "Give me a recap of the Q2 brand partnership."

**When NOT to use:** report QA before sending (use `report-preflight`), a single
broken/erroring deliverable (use `deliverable-repair`), or "are our accounts
connected" (use `connection-audit`).

## Ethics floor (always applies)

> *The creator's inbox and the client's trust are the commons.*

- **Never fabricate or extrapolate a stat.** Every number traces to a tool call.
  If you don't have a number, say so — don't estimate, round up, or infer it.
- **Never present stale or errored stats as current** without flagging them.
- **Never auto-send a report to a client.** Preparing is not sending.
- **Flag missing data before sharing — don't hide it.**
- **If a fix needs the user to act in InfluenceKit**, say so plainly.

## Tools this routine uses

- **list_campaigns** — List campaigns, optionally filtered by status (active,
  completed, draft, etc.). Use this to find the campaign the user means.
- **get_campaign** — Get detailed information about a specific campaign,
  including its deliverables summary, date range, and performance overview.
- **get_deliverable** — Get full details for a specific deliverable, including
  its current stats (reach, impressions, engagement, clicks), content type,
  platform, URL, and status.

No other tools. This routine never writes or sends anything.

## How to run it

1. **Find the campaign.** If the user named it, use `list_campaigns` (filter by
   status) to resolve it to a campaign ID. If the name is ambiguous, list the
   candidates and ask which one — don't guess.
2. **Pull the overview.** Use `get_campaign` for the deliverables summary, date
   range, and performance overview.
3. **Pull per-deliverable stats**, capped (see Cap below). Use `get_deliverable`
   on each deliverable you intend to rank.
4. **Rank by an actual metric.** Default to reach; if reach is missing for some
   items, state which metric you ranked on and why.
5. **Break down by platform** from the stats you pulled.
6. **Write 2–3 insights drawn only from the numbers.** "The two Reels out-reached
   the four static posts 3:1" is allowed. "Reels work better because the
   algorithm favors video" is **not** — that's speculation, not data.
7. **Flag any deliverable with missing or errored stats** instead of dropping it.

## Cap (no silent truncation)

This routine fans out `get_deliverable` per item. **Fetch at most the first 25
deliverables** returned by `get_campaign`. If the campaign has more, rank the 25
you fetched and state in the output exactly how many deliverables exist, how many
you fetched, and how they were selected. Never silently truncate.

## Output format (fixed)

```
# Recap: <Campaign name> (<date range>)

## Headline
- Deliverables: <n fetched> of <n total>
- Total reach: <sum>
- Total impressions: <sum>
- Avg engagement rate: <value> (across deliverables with engagement data)

## Top deliverables (ranked by <metric>)
1. <platform> — <content type> — reach <x>, eng rate <y> — <url>
2. ...

## Platform breakdown
- Instagram: <n> deliverables, reach <x>
- TikTok: ...

## Insights (from the numbers only)
- <insight 1>
- <insight 2>

## Needs attention
- <deliverable> — <missing stats / errored / stale> (flagged, not dropped)
```

## Worked example

> **Illustrative only — every number below is a placeholder.** In a real run,
> each figure comes from a `get_campaign` / `get_deliverable` call.

User: *"How did our Spring Launch campaign do?"*

1. `list_campaigns(status: "completed")` → resolves "Spring Launch" to id `812`.
2. `get_campaign(id: 812)` → 9 deliverables, ran Mar 1–Apr 15.
3. `get_deliverable` on all 9 (under the 25 cap).

```
# Recap: Spring Launch (Mar 1 – Apr 15)

## Headline
- Deliverables: 9 of 9
- Total reach: 412,000
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
