# InfluenceKit Claude Plugin

Connect Claude to your InfluenceKit account to manage campaigns, track
performance, troubleshoot deliverables, and prepare reports.

## Prerequisites

- [Claude Code](https://claude.ai/claude-code) v1.0.33+
- An InfluenceKit admin account
- InfluenceKit MCP connection configured in Claude Desktop

## Installation

**Step 1** — Add the InfluenceKit marketplace:

```
/plugin marketplace add InfluenceKit/claude-plugin
```

**Step 2** — Install the plugin:

```
/plugin install influencekit
```

## What you get

The plugin ships a small set of **single-purpose routines** — sharp, focused
skills that each auto-load when their job matches what you're asking. Instead of
one giant "do everything" skill, each routine knows exactly one thing and does it
well, on top of the 10 InfluenceKit MCP tools.

| Routine | Use it when |
|---------|-------------|
| **campaign-recap** | "How is campaign X doing? Which content won?" — totals, ranked deliverables, platform breakdown. |
| **report-preflight** | "Is this report client-ready before I send it?" — pass/fail QA of every included deliverable. |
| **deliverable-repair** | "This post has no stats — fix it." — diagnose one broken deliverable and repair (or escalate). |
| **connection-audit** | "Are all our social accounts healthy?" — account-wide connection health and a reconnect list. |

A top-level **influencekit** skill gives orientation, the key concepts, and the
full 10-tool reference, and points you to the right routine.

## The ethics floor

Every routine operates under one short, non-negotiable floor:

> *The creator's inbox and the client's trust are the commons.* Never fabricate
> or extrapolate a stat — every number traces to a tool call. Never present
> stale/errored stats as current without flagging. Never auto-send a report to a
> client. Flag missing data before sharing, don't hide it. If a fix needs you to
> act in InfluenceKit, the routine says so plainly.

Canonical copy: [`plugins/influencekit/skills/ETHICS.md`](plugins/influencekit/skills/ETHICS.md).

## Example usage

Once installed, just ask Claude naturally:

- "How is our summer campaign doing?"
- "Why isn't this Instagram post showing any stats?"
- "Check if all our social connections are healthy."
- "Review my Q1 report for any issues before I send it."

## Roadmap

The current MCP is read + ops only. The write-side surfaces that unlock the next
routines (report building, media kits, creator discovery, audience quality, rate
guidance) are documented — not yet built — in
[`docs/mcp-routines-roadmap.md`](docs/mcp-routines-roadmap.md).

## Support

- [InfluenceKit Help](https://help.influencekit.com)
- [support@influencekit.com](mailto:support@influencekit.com)

## License

MIT
