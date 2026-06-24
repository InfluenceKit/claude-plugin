---
name: report-builder
description: >-
  Use when assembling a shareable InfluenceKit report from a set of content URLs
  for a creator/influencer account — create the report, attach the deliverables,
  set any off-platform numbers (e.g. newsletter reach), and return the share link.
  Triggers on "build a report for these posts", "put these URLs in a report",
  "add my newsletter stats to the report", "make me a client-ready report link".
when_to_use: >-
  Creating and populating an event-backed report on an INFLUENCER/creator account.
  NOT for QAing a report that already exists (use report-preflight), NOT for
  brand/campaign reporting (brands report on campaigns/assignments, not events),
  NOT for fixing one broken deliverable (use deliverable-repair). This routine
  creates and prepares a report; it NEVER sends or shares it to a client.
---

# Report Builder

**Role: influencer / creator accounts.** `create_report`, `add_deliverable`,
`create_event`, and `delete_event` are gated to creator accounts (they return a
plain "only available for influencer accounts" error on a brand account). Brands
report on campaigns and assignments instead. If you're on a brand account, stop
and use `campaign-recap` / `query_campaign_data`.

## Overview

Turn a list of content URLs into one shareable report, end to end: create the
report (which also creates its backing **event**), attach the deliverables, fill
in any numbers the platform can't auto-pull (newsletter reach/impressions, a
display label, a corrected content type), and hand back the **share_url**. In
InfluenceKit a report is the report *of* one event, so `create_report` and
`add_deliverable` both hang off an `event_id`.

This is the proven agent-runner workflow (e.g. an Airtable row → "build report"):
the agent assembles the report from structured input and **writes the share_url
back** to the row. The agent prepares the link; a human decides to send it.

## Ethics floor (always applies)

> *The creator's inbox and the client's trust are the commons.*

- **Never fabricate or extrapolate a stat.** Manual numbers (newsletter reach,
  impressions) come **from the user or the source**, entered verbatim. If a
  number wasn't given, leave it blank and say so — don't estimate it.
- **Never present stale or errored stats as current** without flagging them.
- **Never auto-send or auto-share the report.** Returning the `share_url` is not
  sending it; the human (or the row's owner) decides who gets the link.
- **Flag missing data before sharing — don't hide it.**
- **If a fix needs the user to act in InfluenceKit**, say so plainly.

## Tools this routine uses

- **create_report** — Create (or fetch) the **event-backed** report. Pass `name`
  to create a new event + report in one step; it returns `event_id`, `share_url`
  (`/reports/view/<token>`), and `url`. Pass an existing `event_id` to get that
  event's single report (one report per event).
- **add_deliverable** — Add content to the event: `event_id` + `urls` (one per
  line or comma-separated), plus an optional `description` note attached to each
  saved deliverable. Returns `saved` (with each new deliverable's `id`),
  `duplicates`, and `failed`.
- **update_deliverable** — Patch one deliverable by `deliverable_id`: set `title`
  (the card's display label, e.g. "Facebook 6"), `description`, `provider` (fix
  the detected type — e.g. `beehiiv` so a newsletter isn't shown as a generic
  "url"/Article), and **manual** `reach`/`impressions` for off-platform content
  the API can't pull (newsletters). Reach is stored as a manual `impressions_unique`
  stat; impressions as a manual `impressions` stat.
- **create_builder_report** *(alternative)* — A **free-form, filter-based** report
  (not tied to one event): `name` + at least one filter (`providers`,
  `start_date`/`end_date`, `tags`, `events`, `calendars`, ...). Use this when the
  report is "all my Instagram in Q1" rather than "these specific URLs." Unlike
  `create_report`, it is not influencer-gated.
- **delete_report** / **delete_event** *(cleanup)* — `delete_report` removes a
  report + its share link but keeps the event/deliverables; `delete_event` removes
  the event **and** its deliverables and report. Both are destructive — only for
  cleaning up a duplicate/mistaken build, and only after confirming with the user.

## How to run it

1. **Confirm the inputs.** You need a report **name** and the list of **URLs**.
   Manual numbers (newsletter reach/impressions), per-item labels, and provider
   corrections are optional — gather whatever the user/source provided. Don't
   invent any of them.
2. **Create the report.** `create_report(name: "<name>")` → capture `event_id`
   and `share_url`. (If the user pointed at an existing event/report, pass that
   `event_id` instead so you don't create a duplicate.)
3. **Attach the deliverables.** `add_deliverable(event_id:, urls:, description:)`.
   Capture each saved deliverable's `id`. Note any `duplicates` (already present)
   and `failed` URLs — report them, don't silently drop them.
4. **Apply per-item overrides only where the user gave you data.** For each
   deliverable that needs it, `update_deliverable(deliverable_id:, ...)`:
   - a display label → `title`
   - a wrong content type (newsletter shown as "url") → `provider: "beehiiv"`
     (or the right one: `mailchimp`, `convertkit`, `aweber`, ...)
   - off-platform numbers the source gave you → `reach:` and/or `impressions:`
5. **Verify.** The deliverables you added appear in the report automatically.
   Spot-check with `get_report`/`query_report_data` if you changed types or set
   manual stats, so the report reflects what you intended.
6. **Return the share_url** (and write it back to the source row if that's the
   workflow). Tell the user what's in the report, what you set manually, and what
   was skipped — then stop. **You do not send it.**

## Cap (no silent truncation)

`add_deliverable` takes many URLs in one call, but **per-item `update_deliverable`
fan-out is capped at 50 deliverables per run**. If the build needs manual
overrides on more than 50 items, apply the first 50, then state exactly how many
remain and that the report is **not** finished until they're set. Never imply a
partial build is complete. Likewise, surface every `failed`/`duplicate` URL.

## Output format (fixed)

```
# Report built: <name>

- Report URL (private): /reports/<id>
- Share URL (send-ready, your call to share): <share_url>
- Backing event: <event_id>

## Deliverables added (<n saved>)
1. <provider> — <url> — <label if set> — <manual reach/impressions if set>
2. ...

## Manual values set (from the source, not computed)
- <deliverable id> — reach <x>, impressions <y> (newsletter, no auto-pull)
- <deliverable id> — provider corrected url → beehiiv

## Skipped / needs attention
- Duplicate (already in event): <url>
- Failed to add: <url> — <reason>

## Status
Report is prepared. The share link is yours to send — I have not shared it.
```

## Worked example

> **Illustrative only — every value is a placeholder.** Real ids and the share
> URL come from the `create_report` / `add_deliverable` calls.

User (or Airtable row): *"Build a report 'Kidding Around Media — June' with these
3 URLs; the beehiiv newsletter got 5,200 opens (reach) and 7,000 impressions;
label the Facebook one 'Facebook 6'."*

1. `create_report(name: "Kidding Around Media — June")` → `event_id: 8810`,
   `share_url: /reports/view/abc123`.
2. `add_deliverable(event_id: 8810, urls: "<ig>\n<fb>\n<beehiiv>")` →
   saved ids `[51, 52, 53]`; the beehiiv one (`53`) came in as provider `url`.
3. `update_deliverable(deliverable_id: 53, provider: "beehiiv", reach: 5200, impressions: 7000)`
   and `update_deliverable(deliverable_id: 52, title: "Facebook 6")`.

```
# Report built: Kidding Around Media — June

- Report URL (private): /reports/3047
- Share URL (send-ready, your call to share): /reports/view/abc123
- Backing event: 8810

## Deliverables added (3)
1. instagram — instagram.com/p/... 
2. facebook — facebook.com/... — label "Facebook 6"
3. beehiiv — <newsletter url> — reach 5,200, impressions 7,000

## Manual values set (from the source, not computed)
- 53 — reach 5,200, impressions 7,000 (newsletter, no auto-pull)
- 53 — provider corrected url → beehiiv

## Skipped / needs attention
- (none)

## Status
Report is prepared. The share link is yours to send — I have not shared it.
```
