# InfluenceKit Routines — MCP Gap Roadmap

**Status:** documented, not built. This file describes what the InfluenceKit MCP
would need in order to unlock the next waves of routines. None of these tools
exist today; **do not reference them from any `SKILL.md`** — the v1 routines are
grounded strictly in the 10 shipped tools (`list_tenants`, `get_tenant`,
`list_campaigns`, `get_campaign`, `get_deliverable`, `get_report`,
`check_connection`, `diagnose_deliverable`, `refresh_deliverable`,
`clear_deliverable_error`).

The v1 routines ship against those 10. Everything below is the prioritized
backlog: each MCP gap, the routines it unlocks, and the read-vs-write and
auth-scope notes that gate it.

---

## Why there's a gap at all

Two properties of today's MCP shape the whole roadmap:

1. **Read + ops only.** The toolset can read campaigns/deliverables/reports and
   run a handful of repair ops (clear error, refresh). It cannot *create* —
   no report creation, no media kits, no content. InfluenceKit's signature
   surfaces (media kits, discovery, report building) are all write-side.
2. **Admin-scoped / cross-tenant.** `list_tenants` searches across all accounts
   and the MCP requires an admin account. That makes v1 an operator tool, not a
   per-creator self-service one. Public self-service needs a tenant-scoped auth
   mode (item 6).

---

## Priority backlog (highest leverage first)

### 1. Report write-side — `create_report`, `add_deliverable_to_report`

- **Inputs:** `create_report(tenant_id, name, deliverable_ids[])`;
  `add_deliverable_to_report(report_id, deliverable_id)`.
- **Outputs:** the new/updated report with its deliverable set.
- **Read vs write:** **write.** First true creation tools in the MCP.
- **Auth scope:** tenant-scoped; writing a report into the wrong tenant is a data
  leak. Gate hard.
- **Routines unlocked:** `report-builder` (assemble a client report from a
  campaign's winning deliverables) — the natural follow-on to `campaign-recap`
  and `report-preflight`, which today can only read and QA reports a human built.

### 2. Media kit read/write — `get_media_kit`, `update_media_kit`

- **Inputs:** `get_media_kit(tenant_id)`; `update_media_kit(tenant_id, sections)`.
- **Outputs:** the creator's media-kit content (audience stats, rates, past
  partnerships, sample content).
- **Read vs write:** read + write.
- **Auth scope:** tenant-scoped; media kits are a creator's public-facing asset.
- **Routines unlocked:** `media-kit-builder` — InfluenceKit's signature creator
  feature, absent from the MCP entirely today.

### 3. Discovery — `find_creators`, `search_creators`

- **Inputs:** `search_creators(filters: { niche, platform, audience_size,
  location, ... })`.
- **Outputs:** ranked creator candidates with headline audience metrics.
- **Read vs write:** read.
- **Auth scope:** brand/agency-scoped; this is the brand pack's entry point.
- **Routines unlocked:** `creator-discovery`, and feeds `brand-deal-fit-check`.

### 4. Audience quality — `get_creator_audience`

- **Inputs:** `get_creator_audience(creator_id)`.
- **Outputs:** audience demographics, authenticity / fake-follower signals,
  engagement-quality breakdown.
- **Read vs write:** read.
- **Auth scope:** brand/agency-scoped (with creator-consent considerations).
- **Routines unlocked:** `audience-authenticity` — audience-quality vetting that
  the current toolset can't touch.

### 5. Rate / benchmark read

- **Inputs:** a benchmark read keyed on platform + audience size + niche.
- **Outputs:** typical rate ranges and performance benchmarks.
- **Read vs write:** read.
- **Auth scope:** could be platform-wide (aggregated) rather than tenant-scoped.
- **Routines unlocked:** `rate-advisor` — pricing guidance for creators and
  brands.

### 6. Tenant-scoped auth mode

- **What:** an auth mode that scopes the MCP to a single tenant instead of
  admin/cross-tenant.
- **Read vs write:** infrastructure, not a tool.
- **Why it's on the list:** it's the **prerequisite** for any public, per-creator
  self-service use of these routines. Until it lands, the audience stays
  agency/operator. It gates the whole creator pack from going public.

---

## v2 routines (NOT built — listed for coherence)

Each maps to a backlog item above and should ship only after its dependency
lands.

### Creator pack

- **media-kit-builder** — needs item 2 (`get_media_kit` / `update_media_kit`).
- **rate-advisor** — needs item 5 (rate / benchmark read).
- **brand-deal-fit-check** — needs items 3–4 (discovery + audience).
- **disclosure-checker** — FTC `#ad` / disclosure compliance pass over a
  campaign's deliverables. Partially doable on read tools today; full version
  wants content-level access.
- **report-builder** — needs item 1 (report write-side).

### Brand / agency pack

- **creator-discovery** — needs item 3 (discovery).
- **audience-authenticity** — needs item 4 (`get_creator_audience`).
- **campaign-brief** — generate a brief; needs campaign write-side.
- **outreach** — creator outreach with a hard anti-spam gate; needs messaging
  surface + the same "never auto-send" floor the v1 routines hold.
- **roi-report** — needs item 1 (report write-side) plus rate/benchmark context.

---

## Guardrails that carry forward to v2

The v1 ethics floor is not v1-specific — it scales with the write-side tools,
where the stakes are higher:

- A write-side `report-builder` must still **never auto-send**.
- `outreach` must hold an explicit anti-spam gate — drafts for human review, not
  auto-sends — exactly the posture the v1 routines take with reports.
- Every audience/discovery number must trace to a tool call; no fabricated
  authenticity scores or invented reach.
