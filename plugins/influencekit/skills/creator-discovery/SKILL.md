---
name: creator-discovery
description: >-
  Use when a brand/agency wants to find influencers to partner with, or to track
  how often the brand itself shows up in AI assistant answers (LLM brand
  visibility / "AI Search"). Triggers on "find creators in <niche>", "show me
  beauty influencers in the UK with >50k followers", "are we mentioned by
  ChatGPT", "run an AI Search check", "which competitors come up in AI answers".
when_to_use: >-
  Brand-side creator sourcing and AI-visibility monitoring. NOT for building or
  QAing reports (use report-builder / report-preflight), NOT for influencer
  self-service (these tools are brand-only). Discovery returns candidates to
  evaluate; it never contacts or invites anyone.
---

# Creator Discovery

**Role: brand / agency accounts.** Every tool here is gated to brand accounts and
returns "only available for brand accounts" otherwise. The AI Search tools also
require AI Search to be enabled on the plan (they say so if it isn't).

## Overview

Two brand jobs, one routine:

1. **Sourcing** — find creators to partner with, filtered by niche, platform,
   location, audience size, and engagement (`influencer_discovery`).
2. **AI visibility ("AI Search")** — track how often the brand is mentioned in AI
   assistant answers, by provider, and what competitors surface
   (`ai_search_status` / `ai_search_results` / `ai_search_queries` /
   `ai_search_run_check`).

To actually *invite* a creator you find, that's the `invitations` tool (under
`campaign-recap`/campaign setup) — discovery stops at the shortlist.

## Ethics floor (always applies)

> *The creator's inbox and the client's trust are the commons.*

- **Never fabricate or extrapolate a stat.** Follower counts, engagement rates,
  and mention rates come from the tools. If a creator has no engagement data,
  say so — don't estimate it. **AI Search reports unavailable providers as
  unavailable, never as "the brand is absent"** — preserve that distinction.
- **Never present stale results as current** — name the check's timestamp.
- **Never auto-contact or auto-invite a creator.** Discovery produces a
  shortlist for a human to review; outreach is a separate, deliberate step.
- **Flag missing data before sharing — don't hide it.**
- **If a capability is off** (AI Search not enabled, no brand profile), say so
  plainly rather than guessing.

## Tools this routine uses

### Sourcing
- **influencer_discovery** — Search creators by `query` (name/handle/keyword),
  `niche`, `platform` (instagram, tiktok, youtube, facebook, twitter, pinterest,
  linkedin, threads, twitch), `location`, `min_followers`/`max_followers`,
  `min_engagement_rate`, `limit` (max 50). Returns ranked candidates with
  headline metrics.

### AI visibility (AI Search)
- **ai_search_status** — Latest completed check: overall `mention_rate` (with a
  confidence interval), per-provider breakdown (with explicit availability),
  active query count.
- **ai_search_results** — Per-query results for a check (defaults to latest):
  which providers mentioned the brand, evidence, competitors, sentiment.
- **ai_search_queries** — List active queries, or **add** one (`query_text` +
  `query_type`: `category_recommendation`, `product_comparison`, or
  `brand_reputation`).
- **ai_search_run_check** — Enqueue a new check (returns the new check id, or the
  already-running one). Checks run async — read `ai_search_status` later for results.

## How to run it

**For sourcing:**
1. **Translate the ask into filters.** Map the request to `influencer_discovery`
   params; pick a sensible `limit` (default 10, max 50).
2. **Search**, then **rank by an actual metric** the results carry (engagement
   rate or followers). State which.
3. **Shortlist** the top candidates with their real numbers. Note any candidate
   missing engagement data instead of inventing it.
4. **Stop at the shortlist.** If the user wants to invite someone, hand off to the
   `invitations` tool — don't contact anyone here.

**For AI visibility:**
1. **Read the latest check** with `ai_search_status`. If it returns `no_checks`,
   offer to run one (`ai_search_run_check`) — but it's async, so don't block.
2. **Drill in** with `ai_search_results` for per-query, per-provider detail and
   competitors.
3. **Tune queries** with `ai_search_queries` (list, or add a tracked query).
4. **Report the mention rate as a band, not a point** (use the CI), name the
   check timestamp, and keep "provider unavailable this run" separate from "brand
   not mentioned."

## Cap (no silent truncation)

`influencer_discovery` is capped at **50 results** server-side; if you requested
fewer, say how many you asked for. Never imply the shortlist is the whole field —
state the filters used and that more candidates may exist beyond the limit. For
AI Search, report on the single check you read (latest unless told otherwise);
don't blend providers that were unavailable into the rate.

## Output format (fixed)

```
# Discovery: <what was searched>

## Filters
- niche/platform/location/followers/engagement: <as used>   limit: <n>

## Shortlist (ranked by <metric>)
1. <name/@handle> — <platform> — <followers> followers, <engagement>% eng — <why a fit, from data>
2. ...

## Missing data
- <creator> — no engagement data returned (not estimated)

## Next step
Review the shortlist; to invite, use the invitations tool (separate, deliberate step).
```

For AI visibility:

```
# AI Search: <brand> (check <id>, <timestamp>)

- Mention rate: <rate>% (95% CI <low>–<high>) across <n> samples
- By provider: <provider>: mentioned <y/n>; <provider>: unavailable this run
- Active queries: <n>

## Notable
- Competitors surfaced: <list>   Sentiment: <as returned>
```

## Worked example

> **Illustrative only — placeholders.** Real candidates/rates come from the tools.

User: *"Find food creators in Minnesota with 20k–100k followers and at least 3%
engagement."*

1. `influencer_discovery(niche: "food", location: "Minnesota", min_followers: 20000, max_followers: 100000, min_engagement_rate: 3, limit: 10)`.

```
# Discovery: food creators in Minnesota, 20k–100k followers, ≥3% engagement

## Filters
- niche: food   location: Minnesota   followers: 20,000–100,000   min eng: 3%   limit: 10

## Shortlist (ranked by engagement rate)
1. @northern.plate — Instagram — 48,000 followers, 5.4% eng — local food, high engagement
2. @twincitieseats — TikTok — 72,000 followers, 4.1% eng — MSP restaurant coverage

## Missing data
- @prairiebites — no engagement rate returned (not estimated)

## Next step
Review the shortlist; to invite, use the invitations tool (separate, deliberate step).
```
