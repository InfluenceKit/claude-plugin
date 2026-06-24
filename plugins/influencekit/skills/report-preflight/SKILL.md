---
name: report-preflight
description: >-
  Use when checking whether a finished report is safe to send to a client —
  auditing every included deliverable for errors, missing stats, or stale data
  before sharing. Triggers on "is this report client-ready", "check my report
  before I send it", "anything wrong with the Q1 report".
when_to_use: >-
  Pre-send QA of one specific, already-built report. NOT for creating a report
  (use report-builder), NOT for summarizing campaign performance (use
  campaign-recap), NOT for repairing a single deliverable end to end (use
  deliverable-repair). This routine NEVER sends the report.
---

# Report Preflight

**Role: any.** Works on a brand or influencer report — every tool here is
read/diagnose and available to both account types.

## Overview

Run a pass/fail preflight on a report before a human sends it to a client. Walk
every included deliverable, flag anything errored / missing / stale, and produce
a short "fix before send" list. This routine **prepares**; it never sends, never
refreshes, never clears. To actually fix a flagged item, hand off to
`deliverable-repair`.

## When to use

- "Is my Q1 report ready to send to the client?"
- "Check this report for any issues before I share it."
- "Anything broken in the brand partnership report?"

**When NOT to use:** creating a report (use `report-builder`), a performance recap
(use `campaign-recap`), or fixing one broken post end to end (use
`deliverable-repair`).

## Ethics floor (always applies)

> *The creator's inbox and the client's trust are the commons.*

- **Never fabricate or extrapolate a stat.** Every number traces to a tool call.
  If you don't have a number, say so — don't estimate, round up, or infer it.
- **Never present stale or errored stats as current** without flagging them.
- **Never auto-send a report to a client.** Preparing is not sending — the human
  sends. A passing preflight is a green light for *them*, not for you.
- **Flag missing data before sharing — don't hide it.**
- **If a fix needs the user to act in InfluenceKit**, say so plainly.

## Tools this routine uses

- **query_report_data** — The composite read: pass `report_id` (or `search`) with
  `include: "deliverables,metrics"` to get the report, its deliverables, and
  aggregate metrics in **one** call. Start here — it is the fastest way to see the
  whole report at once.
- **get_report** — Single report with its deliverables and the public
  **share_url**. Use it to confirm the exact share link and the per-deliverable
  error flags.
- **get_deliverable** — Full detail on one deliverable (stats, error type,
  connection). Use to drill into anything `query_report_data` flagged.
- **diagnose_deliverable** — Plain-language cause + fix for any deliverable that is
  errored or missing stats.
- **check_connection** — One OAuth token's health (`token_id`), when a
  deliverable's problem traces back to its source connection.

This routine is read + diagnose only. It does not refresh, clear, create, or send.

## How to run it

1. **Pull the whole report in one call.** `query_report_data(report_id:,
   include: "deliverables,metrics")`. If the user pasted a URL, resolve it first
   with `resolve_url`; if they named it, use `search`.
2. **Classify each deliverable** as **OK** (recent stats, no error), **errored**,
   **missing stats**, or **stale** (stats present but old for the send context).
3. **Diagnose every non-OK deliverable** with `diagnose_deliverable`; drill with
   `get_deliverable` where you need the raw numbers.
4. **Trace connection-rooted problems** with `check_connection` when a diagnosis
   points at the source account.
5. **Confirm the share link** with `get_report` so what you clear is what they
   will send.
6. **Produce a pass/fail verdict** plus an ordered "fix before send" list, then
   **stop** — it is the human's call to send, and (if anything is broken) to run
   `deliverable-repair` first.

## Cap (no silent truncation)

Audit **every** deliverable the report contains. If the report has more than 50
deliverables, audit the first 50, then state clearly how many remain unaudited and
that the report is **not** cleared until they are. Never imply a partial audit is
a full pass.

## Output format (fixed)

```
# Preflight: REPORT NAME — PASS or FAIL

## Summary
- Deliverables audited: n of n total
- OK: n   Errored: n   Missing stats: n   Stale: n
- Share URL: from get_report

## Flagged deliverables
- deliverable — ERRORED or MISSING or STALE — one-line diagnosis — fix
- ...

## Fix before send (ordered)
1. action the user takes in InfluenceKit, or "run deliverable-repair on that id"
2. ...

## Verdict
PASS: nothing blocking — your call to send.
FAIL: N items must be fixed first; do not send yet.
```

A report **fails** preflight if any included deliverable is errored, missing
stats, or stale. "PASS" means nothing blocking was found — it is still the human
who sends.

## Worked example

> **Illustrative only — placeholders.** Real verdicts come from `query_report_data`
> / `diagnose_deliverable` / `check_connection`.

User: *"Is my Q1 Recap report ready to send?"*

1. `query_report_data(report_id: 305, include: "deliverables,metrics")` returns
   6 deliverables; 4 OK, 1 errored, 1 missing stats.
2. `diagnose_deliverable` on the two non-OK items.
3. `check_connection` on the Instagram token behind the missing-stats post.
4. `get_report(report_id: 305)` to confirm the share URL.

```
# Preflight: Q1 Recap — FAIL

## Summary
- Deliverables audited: 6 of 6
- OK: 4   Errored: 1   Missing stats: 1   Stale: 0
- Share URL: /reports/view/abc123

## Flagged deliverables
- IG Reel "launch teaser" — MISSING — Instagram token expired, stats cannot pull — reconnect Instagram
- TikTok "day in the life" — ERRORED — video URL returns 404, post may be deleted — confirm/replace URL

## Fix before send (ordered)
1. Reconnect the Instagram account in InfluenceKit, then run deliverable-repair on the Reel.
2. Confirm the TikTok URL (or remove the deliverable if the post is gone).

## Verdict
FAIL: 2 items must be fixed first; do not send yet.
```
