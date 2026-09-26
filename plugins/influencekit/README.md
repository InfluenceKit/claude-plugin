# InfluenceKit for Claude

Connect Claude to your InfluenceKit account so it can build and check reports,
recap campaign performance, troubleshoot deliverables that have stopped
collecting stats, and help brands discover creators. It works for brand/agency
accounts and creator accounts; each routine only runs where its tools are
available for your account type.

## What this plugin contains

- **One MCP connector**: the InfluenceKit MCP server at
  `https://api.influencekit.com/mcp` (declared in `.mcp.json`). On first use
  Claude opens InfluenceKit's own sign-in page (OAuth 2.0 with PKCE). You approve
  access there; no password or API key is stored in the plugin.
- **Skills** (plain Markdown instructions, no scripts or hooks):

| Skill | Use it when |
|-------|-------------|
| `influencekit` | Orientation: the account-role model, the tool reference, and pointers to the server's own prompts and knowledge resources. |
| `report-builder` | "Build a shareable report from these post URLs." (creator accounts) |
| `report-preflight` | "Is this report ready to send to the client?" |
| `deliverable-repair` | "This post has no stats, fix it." |
| `connection-audit` | "Are all our connected social accounts healthy?" |
| `campaign-recap` | "How is campaign X doing, and which content won?" |
| `creator-discovery` | "Find creators in this niche" and "are we showing up in AI answers?" (brand accounts) |
| `mcp-setup` | "I can't connect" or "I'm getting a 401." |

Every routine follows the rules in [`skills/ETHICS.md`](skills/ETHICS.md): no
invented stats, stale data is flagged, and a report is never sent or shared on
your behalf.

## What it sends and where

The plugin runs nothing on your machine. Everything goes through the MCP
connector to `api.influencekit.com`, and only for the tools Claude calls: reading
your campaigns, reports, deliverables and connection health, and making the
changes you ask for (creating a report, adding deliverables, refreshing stats).
Claude asks before running any tool that changes data. Deleting a report or an
event also requires you to confirm in your own words.

## Requirements and support

You need an InfluenceKit account (https://www.influencekit.com). Setup help:
https://help.influencekit.com/en/articles/14011645-using-influencekit-with-ai-assistants-mcp.
Questions: support@influencekit.com.

## License

MIT. See [LICENSE](LICENSE).
