#!/usr/bin/env ruby
# frozen_string_literal: true

# Tool-allowlist guard for the InfluenceKit routines.
#
# Verifies that no plugins/influencekit/skills/*/SKILL.md references an MCP tool
# that isn't actually registered in the server. This is the guard the stale
# `list_tenants` phantom slipped past: a routine that names a non-existent tool
# is a broken routine.
#
# Allowlist source, in priority order:
#   1. --mcp-dir PATH  (or MCP_DIR env) -> derive LIVE from a Rails checkout's
#      app/mcp/influencekit_mcp_server.rb TOOLS/PROMPTS arrays. This is the
#      authoritative source; use it in CI that has the Rails app available.
#   2. scripts/tool-allowlist.txt -> a committed snapshot, regenerated from (1).
#
# Usage:
#   MCP_DIR=/path/to/influencekit/app/mcp ruby scripts/check_tool_allowlist.rb
#   ruby scripts/check_tool_allowlist.rb            # uses the snapshot
#
# stdlib only; no Rails, no gems.

require "set"

ROOT = File.expand_path("..", __dir__)
SKILLS_GLOB = File.join(ROOT, "plugins", "influencekit", "skills", "*", "SKILL.md")
SNAPSHOT = File.join(__dir__, "tool-allowlist.txt")

# snake_case identifiers that legitimately appear in routines but are NOT tools:
# tool params, enum values, resource/frontmatter keys, and the deliberately-cited
# non-tool `list_tenants` (named only to say it does not exist).
IGNORE = %w[
  when_to_use
  list_tenants
  session_context
  account_type brand_account influencer_account
  tenant_id tenant_subdomain
  event_id deliverable_id report_id campaign_id token_id
  reportable_id reportable_type
  query_object query_text query_type
  has_error start_date end_date
  min_followers max_followers min_engagement_rate
  check_id user_limit connection_limit
  access_token share_url signup_link next_step
  impressions_unique provider_published_at
  no_checks instagram_stories tik_tok
  category_recommendation product_comparison brand_reputation
  partner_campaign partner_campaigns
  expires_at mention_rate account_mismatch
].to_set

def derive_from_source(mcp_dir)
  server = File.join(mcp_dir, "influencekit_mcp_server.rb")
  raise "no influencekit_mcp_server.rb in #{mcp_dir}" unless File.exist?(server)
  src = File.read(server)

  names = Set.new
  %w[TOOLS PROMPTS].each do |const|
    block = src[/#{const}\s*=\s*\[(.*?)\]\.freeze/m, 1]
    next unless block
    block.scan(/\b([A-Z][A-Za-z0-9]+)\b/).flatten.uniq.each do |klass|
      file = Dir.glob(File.join(mcp_dir, "*.rb")).find { |f| File.read(f) =~ /class\s+#{klass}\b/ }
      next unless file
      if (m = File.read(file)[/\b(?:tool_name|prompt_name)\s+["']([a-z0-9_]+)["']/, 1])
        names << m
      end
    end
  end
  names
end

def load_snapshot
  File.readlines(SNAPSHOT, chomp: true)
      .map { |l| l.sub(/#.*/, "").strip }
      .reject(&:empty?)
      .to_set
end

mcp_dir = nil
if (i = ARGV.index("--mcp-dir")) && ARGV[i + 1]
  mcp_dir = ARGV[i + 1]
elsif ENV["MCP_DIR"] && !ENV["MCP_DIR"].empty?
  mcp_dir = ENV["MCP_DIR"]
end

if mcp_dir && File.directory?(mcp_dir)
  allowed = derive_from_source(mcp_dir)
  source = "live source: #{mcp_dir}"
else
  allowed = load_snapshot
  source = "committed snapshot: #{File.basename(SNAPSHOT)}"
end

abort "Allowlist is empty (#{source})" if allowed.empty?

token_re = /\b[a-z][a-z0-9]*(?:_[a-z0-9]+)+\b/
files = Dir.glob(SKILLS_GLOB).sort
violations = []
files.each do |f|
  File.read(f).scan(token_re).uniq.each do |tok|
    next if allowed.include?(tok) || IGNORE.include?(tok)
    violations << [f, tok]
  end
end

puts "Tool-allowlist check"
puts "  #{source}"
puts "  allowed tokens: #{allowed.size}"
puts "  SKILL.md files: #{files.size}"

if violations.empty?
  puts "PASS — every tool token in every routine is in the MCP registry."
  exit 0
end

puts "FAIL — tokens referenced that are not real MCP tools (and not in IGNORE):"
violations.each { |f, t| puts "  #{File.basename(File.dirname(f))}/SKILL.md -> #{t}" }
puts
puts "If a flagged token is a legitimate param/value (not a tool), add it to IGNORE."
puts "If it is meant to be a real tool, the snapshot is stale — regenerate via --mcp-dir."
exit 1
