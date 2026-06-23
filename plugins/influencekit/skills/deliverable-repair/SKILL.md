---
name: deliverable-repair
description: >-
  Use when one specific deliverable is broken — showing an error, stuck, or
  missing its stats — and needs diagnosing and fixing. Triggers on "this post
  has no stats", "fix this deliverable", "why is this one erroring", "this
  Instagram post won't update".
when_to_use: >-
  Repairing a single, identified deliverable end to end. NOT for ranking
  campaign performance (use campaign-recap), NOT for auditing a whole report
  before sending (use report-preflight), NOT for an account-wide connection
  sweep (use connection-audit).
---

# Deliverable Repair

## Overview

Take one broken deliverable from symptom to fix: diagnose the cause, take the
safe automated actions you can (clear a stuck error, refresh stats), confirm the
result, and **escalate to the user when the fix needs a login or reconnect** in
InfluenceKit. One deliverable at a time — this is the narrow, surgical routine.

## When to use

- "Why doesn't this Instagram post have any stats?"
- "This deliverable is showing an error — can you fix it?"
- "The reach on this one hasn't updated in a week."

**When NOT to use:** a campaign recap (use `campaign-recap`), a full report
preflight (use `report-preflight`), or a sweep of all connections (use
`connection-audit`).

## Ethics floor (always applies)

> *The creator's inbox and the client's trust are the commons.*

- **Never fabricate or extrapolate a stat.** Every number traces to a tool call.
  If you don't have a number, say so — don't estimate, round up, or infer it.
- **Never present stale or errored stats as current** without flagging them.
- **Never auto-send a report to a client.** Preparing is not sending.
- **Flag missing data before sharing — don't hide it.**
- **If a fix needs the user to act in InfluenceKit** (reconnect an account,
  update a URL, log in), say so plainly. Not every problem is fixable through the
  tools — when it isn't, stop and hand it back to the user.

## Tools this routine uses

- **diagnose_deliverable** — Run a diagnostic check on a deliverable that's
  showing errors or missing stats. Returns a plain-language explanation of
  what's wrong and specific steps to fix it. **Always start here.**
- **check_connection** — Check whether a social connection's OAuth token is
  healthy and able to pull data. Use when the diagnosis points at the source
  account.
- **clear_deliverable_error** — Clear the error state on a deliverable so it can
  be retried. Use when a deliverable is stuck in an error state and the cause is
  on InfluenceKit's side (not a platform or permissions problem).
- **refresh_deliverable** — Tell InfluenceKit to re-fetch stats from the social
  platform. Use after the underlying issue is resolved.
- **get_deliverable** — Get full details for a specific deliverable, including
  its current stats and status. Use to confirm the fix landed.

## How to run it

1. **Diagnose first.** Always run `diagnose_deliverable` before touching
   anything. It gives the clearest picture and prevents blind fixes.
2. **If the cause is a connection/permissions problem**, run `check_connection`
   to confirm, then **stop and escalate**: tell the user to reconnect the account
   in InfluenceKit. Clearing/refreshing won't help until they do. Do not loop.
3. **If the error is on InfluenceKit's side** (stuck error state, transient
   failure), use `clear_deliverable_error` to reset it.
4. **Refresh.** Once the blocker is cleared (or the user confirms they
   reconnected), use `refresh_deliverable` to pull fresh stats.
5. **Confirm.** Use `get_deliverable` to verify stats came through. Stats can lag
   a moment after a refresh — if unchanged immediately, say so rather than
   declaring success.
6. **Report** the diagnosis, the action taken, and the confirmed result — or the
   exact action you've handed back to the user.

## Escalation rule (no dead loops)

If the fix requires the user to act in InfluenceKit (reconnect, re-auth, fix a
URL), **escalate and stop**. Do not repeatedly clear/refresh against a broken
connection — it won't work and it burns API calls. Hand it back plainly.

## Cap

Single deliverable per run by design. If the user points at several broken posts,
say so and route to `report-preflight` (whole report) or handle them one at a
time — don't silently fix only the first.

## Output format (fixed)

```
# Repair: deliverable <id> (<platform> <content type>)

## Diagnosis
<plain-language cause from diagnose_deliverable>

## Action taken
- <clear_deliverable_error: yes/no — why>
- <refresh_deliverable: yes/no>
- <or: escalated to user — what they must do in InfluenceKit>

## Result
<confirmed stats from get_deliverable, or "still pending — checked again, no change yet", or "blocked on user reconnect">
```

## Worked example

> **Illustrative only — placeholders.** Real causes/stats come from the tools.

User: *"This Instagram post isn't showing any stats — can you fix it?"*

1. `diagnose_deliverable(id: 99012)` → "Instagram token expired; stats can't be
   pulled until the account is reconnected."
2. `check_connection` on that Instagram account → confirms token is invalid.
3. Cause is permissions → **escalate, do not clear/refresh.**

```
# Repair: deliverable 99012 (Instagram Reel)

## Diagnosis
The Instagram account this post belongs to has an expired OAuth token, so
InfluenceKit can't pull its stats. This is a reconnect issue, not a stuck error.

## Action taken
- clear_deliverable_error: no — the error is on Instagram's side, not InfluenceKit's.
- refresh_deliverable: no — it would fail against the expired token.
- Escalated to user: reconnect the Instagram account in InfluenceKit (Settings →
  Connections), then I can refresh this deliverable.

## Result
Blocked on user reconnect. Once you've reconnected, tell me and I'll refresh and
confirm the stats.
```

Contrast — when the fix *is* in scope: if `diagnose_deliverable` reports a stuck
InfluenceKit-side error (healthy connection), then `clear_deliverable_error` →
`refresh_deliverable` → `get_deliverable`, and report the confirmed stats.
