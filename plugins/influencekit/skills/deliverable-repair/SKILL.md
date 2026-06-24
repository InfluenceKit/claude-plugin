---
name: deliverable-repair
description: >-
  Use when one specific deliverable is broken — showing an error, stuck, or
  missing its stats — and needs diagnosing and fixing. Triggers on "this post
  has no stats", "fix this deliverable", "why is this one erroring", "this
  Instagram post won't update", "the type/label on this one is wrong".
when_to_use: >-
  Repairing a single, identified deliverable end to end. NOT for ranking campaign
  performance (use campaign-recap), NOT for auditing a whole report before
  sending (use report-preflight), NOT for an account-wide connection sweep (use
  connection-audit), NOT for assembling a new report (use report-builder).
---

# Deliverable Repair

**Role: any.** All tools here work on brand and influencer accounts.

## Overview

Take one broken deliverable from symptom to fix: diagnose the cause, take the
safe automated actions you can (clear a stuck error, refresh stats, or correct
a mislabeled type/title), confirm the result, and **escalate to the user when the
fix needs a login or reconnect** in InfluenceKit. One deliverable at a time —
this is the narrow, surgical routine.

## When to use

- "Why doesn't this Instagram post have any stats?"
- "This deliverable is showing an error — can you fix it?"
- "The reach on this one hasn't updated in a week."
- "This newsletter is showing up as the wrong content type."

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

- **diagnose_deliverable** — Plain-language cause + a `next_step` hint for a
  deliverable that's erroring or missing stats. **Always start here.**
- **check_connection** — One OAuth token's health (`token_id`). Use when the
  diagnosis points at the source account.
- **clear_deliverable_error** — Clear a stuck error state so the deliverable
  retries. Use when the cause is on InfluenceKit's side, not a platform or
  permissions problem.
- **refresh_deliverable** — Re-fetch stats from the platform API. Use after the
  underlying issue is resolved.
- **update_deliverable** — Fix metadata that is itself the problem: a wrong
  `provider`/type (e.g. a newsletter detected as a generic `url` → set `beehiiv`),
  a wrong `title`/`description`, or — for off-platform content with no auto-pull —
  manual `reach`/`impressions` the user provides. Use this when the deliverable
  isn't "broken" so much as mislabeled or un-pullable.
- **get_deliverable** — Full detail; use to confirm the fix landed.

## How to run it

1. **Diagnose first.** Always run `diagnose_deliverable` before touching anything.
   Honor its `next_step` hint — it already distinguishes "reconnect needed" from
   "account mismatch" from "transient."
2. **If the cause is a connection/permissions problem**, run `check_connection`
   to confirm, then **stop and escalate**: tell the user to reconnect the account
   in InfluenceKit. Clearing/refreshing won't help until they do. Do not loop.
   (Note: an `account_mismatch` diagnosis means the connected account doesn't own
   the content's channel — reconnecting the *same* account won't fix it; the user
   must connect the owning account. Relay that, don't route to clear/refresh.)
3. **If it's a metadata problem** (wrong type/label, or off-platform numbers the
   user supplied), fix it directly with `update_deliverable` — no clear/refresh
   needed.
4. **If the error is on InfluenceKit's side** (stuck error state, transient
   failure), use `clear_deliverable_error` to reset it.
5. **Refresh.** Once the blocker is cleared (or the user confirms they
   reconnected), use `refresh_deliverable` to pull fresh stats.
6. **Confirm.** Use `get_deliverable` to verify. Stats can lag a moment after a
   refresh — if unchanged immediately, say so rather than declaring success.
7. **Report** the diagnosis, the action taken, and the confirmed result — or the
   exact action you've handed back to the user.

## Escalation rule (no dead loops)

If the fix requires the user to act in InfluenceKit (reconnect, re-auth, fix a
URL, or connect the account that owns the content), **escalate and stop**. Do not
repeatedly clear/refresh against a broken connection — it won't work and it burns
API calls. Hand it back plainly.

## Cap

Single deliverable per run by design. If the user points at several broken posts,
say so and route to `report-preflight` (whole report) or handle them one at a
time — don't silently fix only the first.

## Output format (fixed)

```
# Repair: deliverable ID (platform / content type)

## Diagnosis
plain-language cause from diagnose_deliverable

## Action taken
- clear_deliverable_error: yes/no — why
- update_deliverable: yes/no — what changed (type/title/manual stat)
- refresh_deliverable: yes/no
- or: escalated to user — what they must do in InfluenceKit

## Result
confirmed stats from get_deliverable, or "still pending — checked again, no change yet", or "blocked on user reconnect"
```

## Worked example

> **Illustrative only — placeholders.** Real causes/stats come from the tools.

User: *"This Instagram post isn't showing any stats — can you fix it?"*

1. `diagnose_deliverable(deliverable_id: 99012)` returns "Instagram token expired;
   stats can't be pulled until the account is reconnected."
2. `check_connection(token_id: ...)` on that Instagram account confirms the token
   is invalid.
3. Cause is permissions → **escalate, do not clear/refresh.**

```
# Repair: deliverable 99012 (Instagram Reel)

## Diagnosis
The Instagram account this post belongs to has an expired OAuth token, so
InfluenceKit can't pull its stats. This is a reconnect issue, not a stuck error.

## Action taken
- clear_deliverable_error: no — the error is on Instagram's side, not InfluenceKit's.
- update_deliverable: no — metadata is fine; the blocker is the token.
- refresh_deliverable: no — it would fail against the expired token.
- Escalated to user: reconnect the Instagram account in InfluenceKit (Settings →
  Connected Accounts), then I can refresh this deliverable.

## Result
Blocked on user reconnect. Once you've reconnected, tell me and I'll refresh and
confirm the stats.
```

Contrast — when the fix *is* in scope: if `diagnose_deliverable` reports a stuck
InfluenceKit-side error (healthy connection), then `clear_deliverable_error` →
`refresh_deliverable` → `get_deliverable`, and report the confirmed stats. If the
problem is a mislabeled newsletter, a single `update_deliverable(provider:
"beehiiv")` is the whole fix.
