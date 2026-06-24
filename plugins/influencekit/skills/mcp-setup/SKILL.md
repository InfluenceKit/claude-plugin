---
name: mcp-setup
description: >-
  Use when someone can't connect to the InfluenceKit MCP, or the connection
  behaves like it isn't really there — 401/unauthorized, OAuth that never
  finishes, "a connector with that URL already exists", "only an admin can
  connect", or tools that aren't callable even though the API looks up. Triggers
  on "I can't connect InfluenceKit", "getting a 401", "the connector won't add",
  "is the MCP server down".
when_to_use: >-
  First-run setup and connection troubleshooting for the InfluenceKit MCP, for
  any account type. NOT for in-app data problems once you're connected (those are
  deliverable-repair / connection-audit — note that "connection" there means a
  social OAuth token, which is a different thing from the MCP connection this
  routine fixes).
---

# MCP Setup

**Role: any (onboarding).** This routine is about getting *Claude's connection to
InfluenceKit* working — not about a social-platform token inside InfluenceKit.
Two different "connections":

- **MCP connection** (this routine) — the connector that lets Claude call
  InfluenceKit tools. Connector URL: **`https://api.influencekit.com/mcp`**.
- **Social connection** (`check_connection`, `connection-audit`) — an OAuth token
  between InfluenceKit and Instagram/TikTok/etc. Don't confuse the two.

## Overview

Get connected, or diagnose why a connection isn't real. The MCP authenticates as
**the logged-in InfluenceKit user** and is **session-scoped to that user's
tenant** — so most failures are auth/identity issues, not server outages. The
authoritative, step-by-step connect guide is the help article; this routine is
the fast triage over the known first-run frictions.

**Help article (source of truth for connect steps):**
`https://help.influencekit.com/en/articles/14011645`

## Ethics floor (always applies)

> *The creator's inbox and the client's trust are the commons.*

- **Don't claim a capability that isn't connected.** If tools aren't callable,
  say "not connected yet" — don't pretend to read data you can't.
- **Never fabricate a stat or a status.** "The server is reachable" is not "I'm
  authenticated as you."
- **You can't connect for the user.** OAuth/login is the user's action in their
  own browser; hand them the exact step, don't loop.
- **Flag what's missing plainly** rather than papering over it.

## The known first-run frictions

| Symptom | What it usually means | What to tell the user |
|---------|-----------------------|-----------------------|
| **401 / unauthorized** on every tool | Not authenticated — OAuth didn't complete, or the session expired. | Re-run the connect/authorize flow for `https://api.influencekit.com/mcp`; finish the InfluenceKit login in the browser window it opens. |
| **OAuth window opens but nothing happens** | Auth started but the redirect never came back (popup blocked, closed too early, wrong tenant subdomain). | Complete the login fully; allow the popup; make sure you log into the **same** InfluenceKit account you want to use. |
| **"a connector with that URL already exists"** | The `https://api.influencekit.com/mcp` connector is already added. | Don't add a second one — open the existing connector and (re)authorize it, or remove and re-add if it's stuck. |
| **"only an admin can connect" / can't add connectors** | The runtime restricts adding connectors to workspace admins. | An admin on the workspace adds/authorizes the connector; or use an account with permission. |
| **"the server is up, but my tools still don't work"** | Your runner reached the URL but isn't acting as an **MCP client** — a plain HTTP GET to the URL is not an MCP session. | The runner must speak MCP (JSON-RPC over Streamable HTTP) and complete OAuth. A non-MCP runner needs the (roadmap) plain-HTTP + API-key mode, which isn't shipped yet — see the roadmap. |

## How to run it

1. **Establish what "connected" means here.** Tools are callable only after the
   connector is added **and** OAuth completes as an InfluenceKit user. "The URL
   responds" is not enough.
2. **Smoke-test once connected.** Call **`get_tenant`** — if it returns your
   account (name/type), you're authenticated and scoped correctly. (`check_connection`
   needs a `token_id`, so `get_tenant` is the better first ping.)
3. **If `get_tenant` fails or there are no tools**, walk the friction table above,
   top to bottom, and match the symptom.
4. **Confirm identity, not just reachability.** If `get_tenant` returns a
   *different* account than expected, the user authed into the wrong tenant —
   re-auth into the intended one.
5. **Hand off cleanly.** Every fix here is a user action (authorize, log in, ask
   an admin). Give the one concrete step and the help-article link; don't retry
   in a loop.

## Cap

This routine sets up / diagnoses the connection only. It does not store
credentials, cannot complete OAuth on the user's behalf, and once connected it
hands off to the data routines (don't start doing report/campaign work from here
— let the matching routine take over).

## Output format (fixed)

```
# MCP setup: <connected | not connected>

## Check
- Connector URL: https://api.influencekit.com/mcp
- Tools callable: <yes/no>
- get_tenant: <returned "<account>" (<type>) | failed: <reason>>

## Diagnosis
<which friction matched, in one line>

## Do this
1. <the one concrete user action>
2. Help: https://help.influencekit.com/en/articles/14011645
```

## Worked example

User: *"I added the InfluenceKit connector but every command says 401."*

A 401 on every tool = not authenticated; the connector is added but OAuth didn't
finish.

```
# MCP setup: not connected

## Check
- Connector URL: https://api.influencekit.com/mcp
- Tools callable: no (401 on get_tenant)
- get_tenant: failed: 401 unauthorized

## Diagnosis
Connector exists but the OAuth login never completed — the calls are unauthenticated.

## Do this
1. Open the existing InfluenceKit connector and re-run "Authorize"; finish the
   InfluenceKit login in the browser window (allow the popup), using the account
   you want to work in.
2. Help: https://help.influencekit.com/en/articles/14011645
```
