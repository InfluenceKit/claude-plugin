# InfluenceKit Plugin for Claude Code

Connect Claude Code to your InfluenceKit account to manage campaigns, track content performance, troubleshoot deliverables, and prepare reports — all from your terminal.

## Prerequisites

- [Claude Code](https://claude.ai/code) v1.0.33 or later
- An InfluenceKit account with admin access
- An active MCP connection to InfluenceKit (provided by your InfluenceKit account)

## Installation

Install the plugin directly from GitHub:

```
/plugin install --source github:InfluenceKit/claude-plugin
```

That's it. The plugin adds an `influencekit` skill to Claude Code with built-in knowledge of InfluenceKit's tools and workflows.

## What you get

After installing, Claude Code understands how to:

- **Look up accounts** — find and inspect InfluenceKit accounts, users, and social connections
- **Manage campaigns** — list campaigns, review deliverables, and check performance stats
- **Track content performance** — pull reach, impressions, engagement, and clicks across Instagram, TikTok, YouTube, Facebook, blogs, and more
- **Troubleshoot issues** — diagnose why stats aren't updating, check connection health, and fix broken deliverables
- **Prepare reports** — review reports for completeness, flag missing data, and summarize results before sharing with clients

## Example usage

```
> How is our Q1 Instagram campaign performing?

> Why aren't stats updating for this TikTok post?

> Check the client report for any issues before I send it

> Which deliverables had the highest engagement this month?

> Are all our social connections healthy?
```

## How it works

This plugin provides Claude Code with a skill file that describes InfluenceKit's MCP tools, common workflows, and troubleshooting patterns. When you ask questions about your campaigns or content, Claude Code uses your InfluenceKit MCP connection to fetch real data and provide actionable answers.

## Help & support

- [InfluenceKit Help Center](https://help.influencekit.com)
- [support@influencekit.com](mailto:support@influencekit.com)

## License

MIT — see [LICENSE](LICENSE) for details.
