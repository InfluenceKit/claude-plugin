---
name: connection-audit
description: >-
  Use when checking the health of every social connection on an account —
  which OAuth tokens are healthy and which need reconnecting — account-wide.
  Triggers on "are all our social accounts healthy", "which connections need
  reconnecting", "why are some accounts not pulling data".
when_to_use: >-
  Account-wide connection health sweep across all of a tenant's social accounts.
  NOT for one broken deliverable (use deliverable-repair), NOT for QA on a
  specific report (use report-preflight), NOT for a campaign performance recap
  (use campaign-recap).
---

# Connection Audit

## Overview

Sweep every social connection on an account and report which OAuth tokens are
healthy and which need the user to reconnect. This is the account-wide health
check — the upstream cause of most "stats aren't updating" problems lives here.

## When to use

- "Are all our social accounts connected properly?"
- "Which connections need to be refreshed?"
- "Why are some of our accounts not pulling data?"

**When NOT to use:** one broken deliverable (use `deliverable-repair`), report
QA (use `report-preflight`), or a performance recap (use `campaign-recap`).

## Ethics floor (always applies)

> *The creator's inbox and the client's trust are the commons.*

- **Never fabricate or extrapolate a stat.** Every status traces to a tool call.
  If you don't have a result, say so — don't assume a connection is healthy.
- **Never present stale or errored stats as current** without flagging them.
- **Never auto-send a report to a client.** Preparing is not sending.
- **Flag missing data before sharing — don't hide it.**
- **If a fix needs the user to act in InfluenceKit** (reconnect an account), say
  so plainly.

## Tools this routine uses

- **get_tenant** — Get full details for a specific account, including its users,
  social connections, subscription plan, and account settings. Use this to
  enumerate every connection on the account.
- **check_connection** — Check whether a social connection's OAuth token is
  healthy and able to pull data. Run this on each connection the account has.

Read-only. This routine never reconnects, refreshes, or sends anything — a
reconnect is always the user's action in InfluenceKit.

## How to run it

1. **Enumerate connections.** Use `get_tenant` to list every social connection on
   the account.
2. **Check each one.** Run `check_connection` per connection (see Cap below).
3. **Classify** each as **Healthy** or **Needs reconnect** (with the reason from
   `check_connection`).
4. **Produce a health table** plus a clear reconnect list of exactly which
   accounts the user must reconnect in InfluenceKit.
5. **Don't reconnect for them** — you can't. Reconnecting is a login action only
   the user can take.

## Cap (no silent truncation)

This routine fans out `check_connection` per connection. Audit **every**
connection `get_tenant` returns, up to **50**. If the account has more than 50
connections, check the first 50 and state plainly how many remain unchecked — a
partial sweep must never read as "all healthy."

## Output format (fixed)

```
# Connection audit: <Account name>

## Health
| Connection | Platform | Status | Note |
|------------|----------|--------|------|
| <name>     | Instagram| Healthy| —    |
| <name>     | TikTok   | Needs reconnect | token expired |

## Summary
- Connections checked: <n> of <n total>
- Healthy: <n>   Needs reconnect: <n>

## Reconnect list (user action in InfluenceKit)
1. <account> — <reason>
2. ...
```

## Worked example

> **Illustrative only — placeholders.** Real statuses come from `get_tenant` /
> `check_connection`.

User: *"Are all of Acme Agency's social accounts healthy?"*

1. `get_tenant(id: 44)` → 4 connections: 2 Instagram, 1 TikTok, 1 YouTube.
2. `check_connection` on each.

```
# Connection audit: Acme Agency

## Health
| Connection        | Platform  | Status          | Note                  |
|-------------------|-----------|-----------------|-----------------------|
| @acme.main        | Instagram | Healthy         | —                     |
| @acme.shop        | Instagram | Needs reconnect | token expired 3d ago  |
| @acmeofficial     | TikTok    | Healthy         | —                     |
| Acme on YouTube   | YouTube   | Needs reconnect | permissions revoked   |

## Summary
- Connections checked: 4 of 4
- Healthy: 2   Needs reconnect: 2

## Reconnect list (user action in InfluenceKit)
1. @acme.shop (Instagram) — token expired; reconnect to resume stats.
2. Acme on YouTube — permissions were revoked; reconnect and re-grant access.
```
