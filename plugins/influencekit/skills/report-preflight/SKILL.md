---
name: report-preflight
description: >-
  Use when checking whether a finished report is safe to send to a client —
  auditing every included deliverable for errors, missing stats, or stale data
  before sharing. Triggers on "is this report client-ready", "check my report
  before I send it", "anything wrong with the Q1 report".
when_to_use: >-
  Pre-send QA of one specific report. NOT for summarizing campaign performance
  (use campaign-recap), NOT for repairing a single deliverable in isolation (use
  deliverable-repair), NOT for an account-wide connection sweep (use
  connection-audit). This routine NEVER sends the report.
---

# Report Preflight

## Overview

Run a pass/fail preflight on a report before a human sends it to a client. Walk
every included deliverable, flag anything errored / missing / stale, and produce
a short "fix before send" list. This routine **prepares**; it never sends.

## When to use

- "Is my Q1 report ready to send to the client?"
- "Check this report for any issues before I share it."
- "Anything broken in the brand partnership report?"

**When NOT to use:** a performance recap (use `campaign-recap`), fixing one
broken post end to end (use `deliverable-repair`), or "are our accounts healthy"
(use `connection-audit`).

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

- **get_report** — Get a report's details along with its included deliverables
  and their stats. Use this to review what's in a report before it's shared.
- **diagnose_deliverable** — Run a diagnostic check on a deliverable that's
  showing errors or missing stats. Returns a plain-language explanation of
  what's wrong and specific steps to fix it.
- **check_connection** — Check whether a social connection's OAuth token is
  healthy and able to pull data. Use this when a deliverable's problem traces
  back to its source connection.

This routine is read + diagnose only. It does not refresh, clear, or send.

## How to run it

1. **Pull the report.** Use `get_report` to get the report and every included
   deliverable with its current stats and status.
2. **Classify each deliverable** as one of: **OK** (recent stats, no error),
   **errored**, **missing stats**, or **stale** (stats present but old relative
   to the report's send context).
3. **Diagnose every non-OK deliverable** with `diagnose_deliverable` to get the
   specific cause and fix.
4. **Trace connection-rooted problems.** When a diagnosis points at the source
   account, use `check_connection` to confirm whether the token is the cause.
5. **Produce a pass/fail verdict** plus an ordered "fix before send" list.
6. **Do not send.** End by telling the user it's their call to send, and what (if
   anything) to fix first.

## Cap (no silent truncation)

Audit **every** deliverable the report contains — a preflight that skips items is
worse than none. If `get_report` returns more than 50 deliverables, audit the
first 50, then state clearly how many remain unaudited and that the report is
**not** cleared until they are. Never imply a partial audit is a full pass.

## Output format (fixed)

```
# Preflight: <Report name> — <PASS | FAIL>

## Summary
- Deliverables audited: <n> of <n total>
- OK: <n>   Errored: <n>   Missing stats: <n>   Stale: <n>

## Flagged deliverables
- <deliverable> — <ERRORED|MISSING|STALE> — <one-line diagnosis> — <fix>
- ...

## Fix before send (ordered)
1. <action the user takes in InfluenceKit, or a tool fix>
2. ...

## Verdict
<PASS: nothing blocking — your call to send.>
<FAIL: N items must be fixed first; do not send yet.>
```

A report **fails** preflight if any included deliverable is errored, missing
stats, or stale. "PASS" means nothing blocking was found — it is still the human
who sends.

## Worked example

> **Illustrative only — placeholders.** Real verdicts come from `get_report` /
> `diagnose_deliverable` / `check_connection`.

User: *"Is my Q1 Recap report ready to send?"*

1. `get_report(id: 305)` → 6 deliverables; 4 OK, 1 errored, 1 missing stats.
2. `diagnose_deliverable` on the two non-OK items.
3. `check_connection` on the Instagram account behind the missing-stats post.

```
# Preflight: Q1 Recap — FAIL

## Summary
- Deliverables audited: 6 of 6
- OK: 4   Errored: 1   Missing stats: 1   Stale: 0

## Flagged deliverables
- IG Reel "launch teaser" — MISSING — Instagram token expired, stats can't pull — reconnect Instagram
- TikTok "day in the life" — ERRORED — video URL returns 404, post may be deleted — confirm/replace URL

## Fix before send (ordered)
1. Reconnect the Instagram account in InfluenceKit, then refresh the Reel.
2. Confirm the TikTok URL (or remove the deliverable if the post is gone).

## Verdict
FAIL: 2 items must be fixed first; do not send yet.
```
