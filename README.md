# InfluenceKit Claude Plugin

Connect Claude to your InfluenceKit account to build and QA reports, recap
campaign performance, troubleshoot deliverables, and discover creators — on top
of the **role-aware InfluenceKit MCP server** (33 tools, 4 prompts, and the
server's own knowledge/craft resources).

## Prerequisites

- [Claude Code](https://claude.ai/claude-code) v1.0.33+
- An InfluenceKit account (brand/agency or creator). The MCP scopes itself to the
  logged-in user's account — most tools are gated by account type.

The plugin **bundles the InfluenceKit MCP connector** (`https://api.influencekit.com/mcp`),
so on Claude Code and Claude Desktop installing it sets up the connection for you —
there's no separate connector to add by hand. You approve a one-time OAuth prompt on
first use and you're done. (ChatGPT and some other assistants add MCP connectors
through their own UI instead — see https://help.influencekit.com/en/articles/14011645,
or ask Claude: the **mcp-setup** routine triages connection problems.)

## Installation

**Step 1** — Add the InfluenceKit marketplace:

```
/plugin marketplace add InfluenceKit/claude-plugin
```

**Step 2** — Install the plugin:

```
/plugin install influencekit
```

**Step 3** — On first use, approve the OAuth prompt to connect your InfluenceKit
account. The bundled connector means there's nothing else to configure.

## What you get

The plugin ships a small set of **single-purpose routines** — sharp, focused
skills that each auto-load when their job matches what you're asking, on top of
the real InfluenceKit MCP tools. Each routine declares its **role** (brand,
influencer, or any) so it only runs where its tools are available.

| Routine | Role | Use it when |
|---------|------|-------------|
| **report-builder** | influencer | "Build a shareable report from these URLs" — create it, attach deliverables, set manual newsletter stats, return the share link. |
| **report-preflight** | any | "Is this report client-ready before I send it?" — pass/fail QA of every included deliverable. |
| **deliverable-repair** | any | "This post has no stats / the type is wrong — fix it." — diagnose one deliverable and repair (or escalate). |
| **connection-audit** | any | "Are all our social accounts healthy?" — account-wide token health and a reconnect list. |
| **campaign-recap** | brand & influencer | "How is campaign X doing? Which content won?" — totals, ranked deliverables, platform breakdown. |
| **creator-discovery** | brand | "Find creators in <niche>" and "are we showing up in AI answers?" |
| **mcp-setup** | any | "I can't connect / I'm getting a 401 / the connector won't add." |

A top-level **influencekit** skill gives orientation: the role model, the real
33-tool reference, and pointers to the MCP's own prompts and knowledge resources
(it points you at those instead of restating the data model).

## The ethics floor

Every routine operates under one short, non-negotiable floor:

> *The creator's inbox and the client's trust are the commons.* Never fabricate
> or extrapolate a stat — every number traces to a tool call. Never present
> stale/errored stats as current without flagging. Never auto-send or auto-share
> a report — creating or preparing a report is not sending it. Flag missing data
> before sharing, don't hide it. If a fix needs you to act in InfluenceKit, the
> routine says so plainly.

Canonical copy: [`plugins/influencekit/skills/ETHICS.md`](plugins/influencekit/skills/ETHICS.md).

## Example usage

Once connected, just ask Claude naturally:

- "Build a report called 'June Recap' from these three post URLs."
- "Add my newsletter's 5,200 opens to that report."
- "How is our summer campaign doing?"
- "Why isn't this Instagram post showing any stats?"
- "Find food creators in Minnesota with 20k–100k followers."
- "Check my Q1 report for any issues before I send it."

## Tool-allowlist guard

`scripts/check_tool_allowlist.rb` verifies that no routine references a tool
outside the real MCP registry. Point it at a Rails checkout to derive the
allowlist live from source, or run it against the committed snapshot:

```
# live, from the Rails app:
MCP_DIR=/path/to/influencekit/app/mcp ruby scripts/check_tool_allowlist.rb
# or against the committed snapshot:
ruby scripts/check_tool_allowlist.rb
```

## Roadmap

Report building, manual stats, discovery, and AI-visibility tracking all shipped.
The genuinely-open gaps (report date-sort, deliverable grouping/packages, CSV
export, newsletter auto-pull, a non-MCP plain-HTTP mode, tenant-scoped public
auth) — and the open question of whether these routines should be generated from
the Rails app — are in [`docs/mcp-routines-roadmap.md`](docs/mcp-routines-roadmap.md).

## Support

- [InfluenceKit Help](https://help.influencekit.com)
- [support@influencekit.com](mailto:support@influencekit.com)

## License

MIT
