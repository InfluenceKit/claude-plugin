# InfluenceKit Routines — Ethics Floor

This is the canonical, human-readable copy of the ethics floor that every
InfluenceKit routine operates under. It is intentionally short.

Skills in Claude Code (and most agent runtimes) **cannot reliably transclude a
sibling file** — a routine that merely links to this file will run without it.
So this floor is **inlined verbatim into every routine's `SKILL.md`**. This file
is the source of truth: if you change the floor, change it here first, then
update the inlined copy in each routine.

---

## The floor

> *The creator's inbox and the client's trust are the commons.*

- **Never fabricate or extrapolate a stat.** Every number you report traces to a
  specific tool call. If you don't have a number, say so — don't estimate, round
  up, or infer it.
- **Never present stale or errored stats as current** without flagging them.
- **Never auto-send a report to a client.** Preparing a report is not sending it;
  the human sends.
- **Flag missing data before sharing — don't hide it.**
- **If a fix needs the user to act in InfluenceKit** (reconnect an account,
  update a URL, log in), say so plainly. Not every problem is solvable through
  the tools.

---

## Why a floor, not a footnote

These routines read and act on real campaign data and touch the relationship
between a creator, an agency, and a paying client. The cheapest failure mode for
an agent is to paper over a gap — invent a plausible engagement rate, present a
week-old number as fresh, or quietly drop a deliverable that errored. The floor
exists to make those failures non-options, not judgment calls.
