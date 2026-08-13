# Oracle plugin: read-only structural critique (eval-1-scope)

Target: `plugins/oracle` at version 0.3.0 (per
`plugins/oracle/.claude-plugin/plugin.json:4`). Read-only audit. No
files were modified.

## Executive summary

The plugin is structurally serious work: the verification cascade is
well-scoped, the four research silos are cleanly differentiated by
substrate (canonical docs / repo metadata / issue tracker / public
forums), the rate-limit hook is the most precisely-engineered piece in
the tree, and the test discipline (shellcheck `-x` plus per-hook
assertion suites) is a model the other plugins in the marketplace do
not match. The single most damaging defect is structural rather than
prompt-craft: there is **no `commands/` directory**, so the five
`/oracle:*` slash commands advertised everywhere (`plugin.json:3`,
`README.md:39-58`, `CHANGELOG.md:39-43`) are in fact implemented as
**user-invocable skills** under `skills/verify`, `skills/research`,
`skills/vet`, `skills/setup`, `skills/budget`. That works in Claude
Code, but it is undocumented, it conflicts with the user-invokable
versus auto-trigger distinction the README itself draws, and it means
the prompt-engineering-fidelity axis below judges five skill bodies
that are masquerading as slash-command dispatchers. The README is
also numerically out of sync: it claims two hooks, three slash
commands, and three auto-trigger skills, while the tree contains
four hooks (`hooks/hooks.json:4-48`), five slash-command-like
surfaces, and three auto-trigger plus five user-invocable skills.
Beyond that, the work has real teeth.

## Per-axis findings

### 1. Coverage

Stated purpose: truth-verification harness + structured ecosystem
research + budget-aware rate-limit gating on a bundled
firecrawl-mcp@3.2.1.

The verification half is well covered. The cascade is defined in three
places that agree on substance:
`hooks/inject-protocol.sh:11-75` (the session-injected protocol),
`skills/verification-protocol/SKILL.md:33-77` (the auto-trigger
reference), and `docs/SEARCH-WORKFLOWS.md:38-53` (the user-facing
preference document the `/oracle:setup` skill imports into the user's
root CLAUDE.md). The PreToolUse install interceptor at
`hooks/intercept-install.sh:1-258` covers 13 package managers and
handles flag-with-arg edge cases that the v0.1.1 changelog entry
specifically called out.

The research half is structurally complete:
`canon-reader.md` (authoritative source material),
`github-archivist.md` (repository archaeology),
`issue-investigator.md` (tracker maturity),
`forum-anthropologist.md` (lived experience), dispatched per the
intensity ladder in `skills/research-protocol/SKILL.md:16-37`.

The budget half is the most rigorously engineered piece. The cost
table at `scripts/cost-table.json:20-71` maps every active
firecrawl-mcp tool name to a cost-scaling rule, and `budget-lib.sh`
implements `estimate_cost` with the right special cases for
`firecrawl_search` (search_cost + scrape_extra, lines 88-99) and
`firecrawl_crawl` (limit-multiplied, lines 100-103).

Gaps:

- **No `commands/` directory.** Every other plugin in this marketplace
  uses real Claude Code slash-command files. Here the slash commands
  are user-invocable skills that match on their description (e.g.
  `skills/verify/SKILL.md:3` "Triggers on the literal slash-command
  form"). The Anthropic plugin docs distinguish `commands/` from
  `skills/`; the README at `README.md:39` advertises slash commands.
  This is a coverage gap that the README papers over.

- **`firecrawl_interact` is referenced in cost-rethinker but not
  cost-tabled.** `agents/cost-rethinker.md:64` lists
  `firecrawl_interact | 2 / browser-minute` in its reference table,
  but the cost table at `scripts/cost-table.json:20-71` defines only
  ten tools and `firecrawl_interact` is not among them. If the user
  ever invokes it, `estimate_cost` returns 0 and the rate-limit-guard
  silently lets the call through. The agent's reference is
  contradicting the cost-table the hook actually reads.

- **The plugin description on `plugin.json:3` says "Four auto-triggering
  knowledge skills" but lists only three.** It also says "Five
  Opus-4.7-primed subagents" (correct -- canon, github, issues, forum,
  cost-rethinker), and "Five slash commands" (also correct against the
  intended surface). The README at `README.md:14-16` then contradicts
  by saying "Two hooks plus three slash commands plus four subagents
  plus three auto-triggering knowledge skills". Three independent
  count-disagreements between artefacts in the same plugin.

- **`/oracle:budget reset` uses a typed-phrase confirmation flow that
  spans turns**, per `skills/budget/SKILL.md:66-79`. There is no
  hook-side enforcement; the skill body asks the user to type the
  phrase but if the model auto-answers as the user, the safety has no
  teeth. This is an inherent limitation of typed-confirmation in an
  LLM context, not a design defect, but it deserves a comment.

### 2. Internal consistency

The slash commands do dispatch the subagents their bodies claim.
`skills/research/SKILL.md:49-57` ("`quick` -> spawn one subagent
(`canon-reader`)"; standard -> two; exhaustive -> four) matches the
intensity ladder in `skills/research-protocol/SKILL.md:18-31`.
`skills/vet/SKILL.md:46-65` enumerates four subagents in parallel,
which matches `agents/*.md`'s "When to invoke" sections naming the
`/oracle:vet dispatch` trigger.

The auto-trigger skill descriptions are precisely targeted. The
`verification-protocol` description at
`skills/verification-protocol/SKILL.md:3` is the model description for
"fire liberally; false negatives are the failure mode" -- it lists
hedge phrases, framework feature-existence claims, standards names,
benchmarks, and forum references all in one trigger string. The
`research-protocol` description at `skills/research-protocol/SKILL.md:3`
and `anti-hype-ranking/SKILL.md:3` both name the specific phrases
("best library for", "alternatives to", "X vs Y") that activate them.

Consistency drift:

- **Agent bodies tell the silo to "load the oracle plugin's
  auto-trigger skills"** (`agents/canon-reader.md:106-110`,
  `github-archivist.md:109-112`, `issue-investigator.md:111-115`,
  `forum-anthropologist.md:83-87`). Auto-trigger skills load
  themselves; the agent does not "load" them. The phrasing is harmless
  but operationally confused -- if the description triggers, the body
  loads; if it doesn't, no manual instruction in the agent body will
  reach inside the harness and force it. Either trust the description
  or use a `Skill` tool call.

- **Tier 2 in the injected session protocol vs Tier 2 in the
  user-invocable verify skill.** `inject-protocol.sh:43-50` names the
  `firecrawl-search` *skill* (user-installed). `verify/SKILL.md:82-105`
  prefers the firecrawl *MCP tools* and only falls back to the skill.
  The injected protocol is older (v0.1.0) and was not updated when the
  plugin-scoped MCP server arrived in v0.2.0. The protocol the agent
  sees first thing at session start tells it to use a skill that may
  not be installed, while the plugin's own /oracle:verify body
  correctly prefers the bundled MCP server.

- **Cost rethinker's tool list** at `agents/cost-rethinker.md:6` is
  `["Read", "Grep", "Glob", "Bash"]`. The body at line 91-93 says it
  reads `~/.claude/plugins/oracle/usage.json`. That works with the
  granted Read tool. But the body at lines 89-90 also says it should
  "Check `.oracle/research/` and `.oracle/findings/` for cached prior
  work" -- which is fine -- and the recommendation pattern at lines
  68-70 says "Skip entirely. Check `.oracle/research/<slug>/`..." but
  the agent has no way to compute the slug if the orchestrator does
  not pass it in. The slug derivation rule lives only in
  `research-protocol/SKILL.md:246-248`. The cost-rethinker does not
  declare `Skill` access to load that protocol, so the slug rule is
  not formally reachable.

### 3. Opus 4.7 prompting fidelity in agent system prompts

Strong on most axes. All four research agent bodies open with a
disciplined "You are an Opus 4.7 agent operating at high effort.
Investigate before answering. Run independent lookups in parallel.
Cite every finding with a URL." block
(`canon-reader.md:17-21`, `github-archivist.md:15-18`,
`issue-investigator.md:14-18`, `forum-anthropologist.md:14-18`,
`cost-rethinker.md:9-15`). That is the canonical four-rule preamble.

Imperative-form discipline is consistent. Second-person addresses
("You specialise in...", "You are read-only") match the Opus 4.7
prompting guidance to use directives over rules. Parallel-tool-call
discipline is explicit: every agent has a "Run independent lookups in
parallel" section with a concrete bulleted dispatch list
(`canon-reader.md:84-104`, `github-archivist.md:64-90`,
`issue-investigator.md:74-102`, `forum-anthropologist.md:54-87`).
This is the most-frequently-violated Opus 4.7 idiom in agent prompts
and the oracle plugin is unusually rigorous about it.

Citation discipline is strong: every agent's "Quality standards"
section says "Every URL you cite has been fetched in the same
invocation" (`canon-reader.md:167-168`, `github-archivist.md:152-153`,
`issue-investigator.md:157-158`, `forum-anthropologist.md:127-131`).
This is the file:line equivalent for web sources.

Drift points:

- **Negative framing slips in.** The user's `~/.claude/CLAUDE.md`
  rules say "replace prohibitions with directives". The agent bodies
  use prohibitions liberally: "You do not read forum opinions"
  (`canon-reader.md:14`), "You are read-only; you never install,
  write, or modify files" (`github-archivist.md:11-12`), "You do not
  call firecrawl tools" (`cost-rethinker.md:14`). These are
  load-bearing scope statements, not stylistic prohibitions, so the
  drift is defensible -- but the Opus 4.7 guidance prefers
  "You read canon, not forum opinions" over "You do not read forum
  opinions". Mostly cosmetic.

- **The "never speculate" rule is stated only twice.** Per the
  user-side guidance, every agent should have an explicit "never
  speculate about code/sources you have not read" rule.
  `canon-reader.md:20-21`, `github-archivist.md:17-18`, and
  `issue-investigator.md:17-18` have it.
  `forum-anthropologist.md:17-18` has "Quote sources verbatim with
  URLs. Never paraphrase a quote; either quote it or do not include
  it" -- which substitutes a different rule for the speculate rule.
  `cost-rethinker.md` has neither; its scope (reasoning, not
  retrieval) arguably makes the rule N/A but a "never invent cost
  numbers for tools not in the cost table" rule would have value.

- **Clarify-vs-assume discipline is absent.** The Opus 4.7 prompting
  bank requires "if a single critical scope question would change the
  implementation, ask one consolidated clarifying question and stop".
  Only the slash-command skills implement this
  (`verify/SKILL.md:32-34`, `research/SKILL.md:36-38`,
  `vet/SKILL.md:39-41`). The subagents themselves have no
  clarify-vs-assume rule. If a research dispatch is genuinely
  ambiguous, the subagent will guess rather than refuse.

- **Effort defaults are stated in the body but not in the
  frontmatter.** Per agent body: "high effort". Per frontmatter:
  `model: inherit` with no `effort` field. Claude Code does not
  currently parse an effort frontmatter, so this is consistent with
  the platform, but the prompting guidance says orchestrators should
  default to `xhigh`. The cost-rethinker (read-only reasoning silo)
  is fine at `high`. The four research silos -- which run in parallel
  and produce the building blocks of every recommendation -- might
  warrant `xhigh`. This is a setting that does not yet exist in
  Claude Code, so the audit is forward-looking rather than corrective.

### 4. Anti-hype and niche-surfacing rules

Consistently applied. `anti-hype-ranking/SKILL.md:13-31` (weigh
down: stars, recent commits, blog buzz, SEO, awesome-lists) and
lines 33-63 (weigh up: spec conformance, API stability statements,
maintainer responsiveness, named downstream usage, forum review
quality) are precise. The niche-surfacing rule at
`anti-hype-ranking/SKILL.md:65-88` names four concrete examples
(fmodel-rust, problem+json libs, Brad Frost, W3C-DTCG) that act as
calibration anchors for the discipline.

Cross-agent reference is consistent:

- `github-archivist.md:57-61` -- "Star count is weak signal... Read
  the `anti-hype-ranking` skill and apply it. A library with 800
  stars and a thoughtful maintainer can outrank one with 80,000."
- `issue-investigator.md:69-72` -- "Defeat the commit-cadence
  heuristic. Two commits in 18 months is NOT abandonment if issues
  are still getting timely responses."
- `forum-anthropologist.md:46-49` -- "Honest minority opinions. When
  most threads praise a tool but one careful long-form post raises
  real concerns, report both. Volume of agreement is weak signal;
  quality of argument is strong signal."
- `canon-reader.md` does not explicitly cite the anti-hype rule (line
  108-109 mentions it as binding when scoring across libraries, which
  is correct -- the canon silo's job is spec conformance and design
  rationale, not ranking).

Synthesis-side enforcement:

- `research-protocol/SKILL.md:65-89` (quick contract) requires
  "Niche but mature" and "Spec-conforming" sections explicitly. The
  quick intensity *forces* niche-surfacing structurally.
- Lines 108-110 (standard contract) require an "Anti-hype check"
  paragraph naming the niche-but-mature options explicitly.
- Lines 147-150 (exhaustive contract) require an "Anti-hype callout"
  paragraph.

That is uniformly applied across all three intensities. The discipline
is the strongest single design decision in the plugin.

One soft drift: the niche-surfacing rule says "name at least one
option outside the popularity default; if none genuinely applies, say
so explicitly" (`anti-hype-ranking/SKILL.md:86-88`). The output
contracts at `research-protocol/SKILL.md:75-77` (`Niche but mature`
heading at quick intensity) make the heading mandatory even when no
niche option exists, which can produce vacuous one-liners. The rule
allows "say so explicitly"; the template should mirror that.

### 5. Bloat and thinness

Word counts per file:
`research-protocol` 1452, `anti-hype-ranking` 960, `verification-
protocol` 1003, `verify` 1027, `vet` 918, `setup` 700, `budget` 686,
`research` 526.

Per the plugin-dev `skill-development` guidance, skill bodies should be
1500-2000 words. **None of the eight skills reaches the bottom of that
band.** Research-protocol comes closest at 1452. The user-invocable
"slash command" skills (verify, vet, research, setup, budget) are
intentionally thin dispatchers -- the README and CHANGELOG explicitly
flag this as the design ("the detailed protocol moved into the
auto-triggering `research-protocol` skill", `CHANGELOG.md:139-141`).
That is correct per the company-docs analogy: the slash-command body
is a calling convention, the auto-trigger skill is the manual.

The thinness defect is on the auto-trigger side, not the user-invocable
side. `anti-hype-ranking` (960 words) and `verification-protocol`
(1003 words) are the binding references for two of the three core
disciplines of the plugin and they are 40-50% under the recommended
length. They each have headroom for: concrete worked examples (verify
has them, the auto-trigger versions do not); a "common errors" section;
a "what this skill is not" section (anti-hype has it, verification
does not); and explicit pairing notes with the rest of the plugin.

Bloat:

- **The agent bodies are within reasonable bounds** (1073-1518 words)
  but `canon-reader.md` at 1518 is the longest, with the most
  inventory-style sections (the standards list at lines 41-56 is a
  catalogue rather than discipline; if the user has a different
  vertical it does not apply). This could be split into a
  "calibration anchors" reference and a tighter operational body.

- **`hooks/intercept-install.sh` at 258 lines** is dense but every
  line is load-bearing. The flag-with-arg exhaustive enumeration
  (lines 193-198) is the kind of completeness Opus 4.7 prompting
  guidance specifically calls "evidence of thinking the problem
  through". Not bloat.

- **The README at 292 lines** is the only file with serious bloat.
  The Limitations section at lines 279-292 is good. The Budget
  tracking section at lines 224-258 duplicates content from
  `skills/budget/SKILL.md`. The Components section at lines 37-135 is
  a summary of every other file in the plugin; if those files have
  good descriptions (they do), the README can compress. The
  numerical inconsistencies in the README's component count (see
  Coverage axis) compound this.

### 6. Allow-list discipline

The discipline is mostly correct.

- Every agent has an explicit `tools:` array in YAML frontmatter
  (`canon-reader.md:6`, `github-archivist.md:6`,
  `issue-investigator.md:6`, `forum-anthropologist.md:6`,
  `cost-rethinker.md:6`).
- Every skill has an explicit `allowed-tools:` field
  (`verify/SKILL.md:5`, `research/SKILL.md:5`, `vet/SKILL.md:5`,
  `setup/SKILL.md:5`, `budget/SKILL.md:5`).
- The auto-trigger skills (`verification-protocol`,
  `research-protocol`, `anti-hype-ranking`) intentionally have no
  `allowed-tools` field because they are reference material, not
  executors. That is consistent with the company-docs analogy.

Gaps and over-grants:

- **The four research subagents are over-granted firecrawl tools they
  rarely need.** Every research agent has the full 10-tool MCP
  surface (`canon-reader.md:6`, `github-archivist.md:6`,
  `issue-investigator.md:6`, `forum-anthropologist.md:6`). The
  forum-anthropologist almost certainly should not have
  `firecrawl_extract` (LLM-based structured extraction is the wrong
  tool for "quote a Reddit comment verbatim"; the right tool is
  `firecrawl_scrape`). The canon-reader does not need
  `firecrawl_agent` (50 credits per run is an extreme cost for
  authoritative source reading, where the URL is usually already
  known). Tighter per-silo allow-lists would shift the cost-rethinker
  agent's job upstream into the harness.

- **The `Skill` tool is granted to every research agent**
  (`canon-reader.md:6`, etc.) -- correct, because they need the
  user-installed firecrawl-* skills as fallback. The user-invocable
  skills (`verify`, `research`, `vet`) also have it. The auto-trigger
  skills do not (correct -- reference material does not invoke).

- **`Agent` is granted to `research/SKILL.md:5` and
  `vet/SKILL.md:5`** so they can dispatch subagents. `verify/SKILL.md:5`
  does NOT grant `Agent` -- correct, since verify is single-tier and
  does not dispatch. `setup/SKILL.md:5` and `budget/SKILL.md:5`
  correctly have only `Bash, Read[, Write, Edit]`.

- **Cost-rethinker's tool list is minimal** (`Read, Grep, Glob,
  Bash`) -- which is right for a pure-reasoning silo. But it has no
  `Skill` access, so it cannot load `anti-hype-ranking` or
  `verification-protocol` even though its analyses sometimes touch
  ranking-quality questions. If the alternatives it surfaces are
  themselves rank-ordered, the discipline should be in scope.

- **No `Write` in cost-rethinker.** Correct; this agent does not
  persist findings. Consistent with the read-only stance.

### 7. The skill-as-company-docs analogy

The CHANGELOG explicitly calls this analogy out at
`CHANGELOG.md:139-141`: "Anthropic skill analogy (skills = company
docs, agents = runtime engines)." The plugin honours it on the
auto-trigger side: `verification-protocol`, `research-protocol`, and
`anti-hype-ranking` are reference-only -- no workflow execution, no
tool calls, no `allowed-tools` field, no dispatch logic. They are
called "binding" by the slash-command bodies that auto-load them.
That is correct skill-as-docs use.

The user-invocable skills muddy the analogy. `verify`, `research`,
`vet`, `setup`, `budget` are workflow-execution skills with bash
blocks and dispatch logic. They serve as the slash-command surface in
the absence of a `commands/` directory. Per the strict Anthropic
distinction, these are slash-command bodies, not skill bodies. They
are correctly named -- `name: verify`, `name: research`, etc., which
gives them the `/oracle:verify` namespace -- but the SKILL.md
container is structurally wrong for what they do.

This is fixable cheaply: move the bodies of `verify`, `research`,
`vet`, `setup`, `budget` into `commands/<name>.md` files with the
matching frontmatter, leave the auto-trigger skills where they are.
The behaviour is the same; the structural integrity matches the
analogy.

## Top 5 sharpest design decisions (keep as-is)

1. **Four-silo decomposition of research.** Canon / repo / issues /
   forum is genuinely orthogonal and the silos do not duplicate each
   other's substrate. Each agent's body explains its own scope
   discipline against the others ("You do not read forum opinions;
   that is the forum-anthropologist's silo", `canon-reader.md:13-15`).
   This is the load-bearing idea in the plugin.

2. **The niche-surfacing rule baked into the output contracts.** Not
   just stated in `anti-hype-ranking` as a discipline, but enforced
   structurally in `research-protocol/SKILL.md:75-77` (quick),
   :108-110 (standard), :147-150 (exhaustive). Discipline encoded in
   the output template will be applied; discipline in a separate file
   will be ignored.

3. **The rate-limit-guard tier ladder.** Silent allow under 80%, soft
   remind 80-95%, ask 95-100% or single-call >=15% or rolling-hour
   over 5000, hard deny over 100%, plus zero-cost calls always pass
   (`hooks/rate-limit-guard.sh:96-126`). The thresholds are
   well-chosen, the single-call hard gate at 15% catches the
   `firecrawl_crawl(limit=1000)` and `firecrawl_agent` patterns
   precisely, and the always-pass for status polls means the
   accounting tools work over-budget.

4. **The `cost-rethinker` "goal restatement before alternatives"
   discipline** (`agents/cost-rethinker.md:106-114`). Most cost
   optimisation fails by optimising the wrong tool for the actual
   intent. The mandatory restatement forces re-grounding before
   alternative-search. This is the single sharpest agent body in the
   tree.

5. **Test discipline.** `tests/run-tests.sh` runs shellcheck with
   `-x` source-following (catches the `source budget-lib.sh` chain),
   `jq empty` against every JSON, and per-hook assertion suites.
   `CHANGELOG.md:51-55` claims 19 file-level pass / 69 assertions.
   No other plugin in this marketplace ships its own test suite. The
   pattern should be lifted into other plugins.

## Top 5 highest-impact improvements (v0.3.1 or v0.4.0)

1. **Move user-invocable skills into a real `commands/` directory.**
   Highest-priority structural fix. Create
   `plugins/oracle/commands/{verify,research,vet,setup,budget}.md`,
   move each `skills/<name>/SKILL.md` body into the matching command
   file, delete the five user-invocable skill directories. Update
   `README.md:39-58` and the plugin description to say "five slash
   commands" once and stop oscillating. Touches no logic, restores
   structural sanity.

2. **Synchronise the count claims across README, CHANGELOG, and
   plugin.json.** Pick one authoritative count -- four hooks, five
   slash commands, five subagents, three auto-trigger skills -- and
   make `README.md:14-16`, `plugin.json:3`, and the SEARCH-WORKFLOWS
   summary at `docs/SEARCH-WORKFLOWS.md:104-118` agree. Currently
   three different documents tell three different stories.

3. **Update `hooks/inject-protocol.sh` Tier 2 to prefer the
   plugin-scoped MCP tools.** The session-injected protocol at
   `inject-protocol.sh:43-50` was written when the firecrawl-search
   *skill* was the only way to reach firecrawl; v0.2.0 added the
   bundled MCP server. The injected text should now say "Tier 2:
   plugin-scoped firecrawl MCP tools (`mcp__plugin_oracle_
   firecrawl__*`); fallback to the firecrawl-search skill when
   `FIRECRAWL_API_KEY` is unset; final fallback to WebSearch +
   WebFetch." The mismatch with `skills/verify/SKILL.md:82-105`
   creates a confused agent at session start.

4. **Add `firecrawl_interact` to the cost table, or remove it from
   the cost-rethinker's reference table.** `cost-rethinker.md:64`
   advertises it; `cost-table.json:20-71` does not define it; the
   rate-limit-guard cannot price it. Either define a real
   `urls_array_length` / `fixed` rule for it (or `browser_minutes`
   if a new scaler is added) or strike it from the cost-rethinker
   reference. The current state is a silent zero-cost free pass.

5. **Bring `verification-protocol` and `anti-hype-ranking` up to
   the 1500-2000 word band.** Both are core discipline references and
   both are 40-50% short. Concrete additions: worked examples
   ("before claiming Next.js 15 is current, run npm view next
   version; output 16.2.6; assert grounded in that"), a
   "common-failure-modes" section, an explicit
   "what-this-skill-is-not" section, and a pairing note with the
   other discipline skill (anti-hype has a pairing note with
   verification at `anti-hype-ranking/SKILL.md:117-122`; the
   reverse pairing is missing). Per the user's CLAUDE.md, the
   plugin-dev/skill-development guidance is normative for this repo.

## Risk list

- **Skill description triggering is the harness's job, not the
  agent's.** Agent bodies that say "load skill X" are stating an
  intent that the harness either fulfils via description-matching
  or does not fulfil at all. If a description does not match, the
  agent body cannot rescue it. The four research agents all have
  these load-instructions; they are belt-and-braces against a
  failure mode that has no recovery path.

- **Typed-confirmation safety on `/oracle:budget reset` is
  weak in an LLM context.** `skills/budget/SKILL.md:66-79` requires
  the user to type `RESET-ORACLE-BUDGET`. If a model takes
  user-impersonation liberty, it could enter that string on the
  user's behalf. The mitigation -- archiving prior state to a `.bak`
  file -- is good and present at lines 73-77. No further mitigation
  is realistic, but the limitation should be acknowledged in the
  README.

- **`estimate_cost` for `firecrawl_crawl` defaults limit to 100 if
  unset** (`budget-lib.sh:100-102`). If a user passes
  `firecrawl_crawl` with no limit argument and the actual server
  default differs, the estimate diverges from reality. The user's
  authoritative source is the firecrawl dashboard, per
  `README.md:285-288`. This is documented but worth re-flagging.

- **`monthly_credits` from `.oracle/budget.json` is read as a raw jq
  expression** at `budget-lib.sh:122-124`. A non-numeric value would
  cause arithmetic failures downstream. The hook traps errors silently
  (`fail_silent`) which means a malformed budget config is invisible.
  Add a sanity check in the hook or `/oracle:budget show`.

- **Slug derivation in cost-rethinker.** The agent body recommends
  cache-checks against `.oracle/research/<slug>/` but the agent
  cannot derive the slug -- the rule lives in
  `research-protocol/SKILL.md:246-248` and the agent has no `Skill`
  tool to load it. In practice the orchestrator passes the slug in,
  but if invoked directly the cache-check path is broken.

- **Agent over-grant of `firecrawl_agent` (50 credits per run)** to
  all four research silos means a single auto-spawned silo can
  consume 50% of the monthly Free-plan budget (1000 credits per
  `cost-table.json:8`). The single-call 15% hard gate fires at 150
  credits on Free; `firecrawl_agent` at 50 stays under, so the gate
  does not catch it. Either bump the single-call gate to 5% on Free
  or remove `firecrawl_agent` from agents that don't need autonomous
  retrieval.

## Concrete diff suggestions

### A. Fix the slash-command structural mismatch

Create `plugins/oracle/commands/verify.md` (and the four siblings)
with the body of the corresponding skill, frontmatter unchanged.
Delete `plugins/oracle/skills/verify/`. The frontmatter `name: verify`
plus the file location `commands/verify.md` becomes the canonical
slash-command surface; the `allowed-tools` line is identical syntax in
both file types.

Before (`plugins/oracle/skills/verify/SKILL.md`):

```
---
name: verify
description: This skill should be used when the user explicitly invokes `/oracle:verify <claim>` ...
argument-hint: <claim or topic to verify>
allowed-tools: Bash, WebSearch, ...
---
```

After (`plugins/oracle/commands/verify.md`):

```
---
description: Run the oracle verification cascade against a claim or topic.
argument-hint: <claim or topic to verify>
allowed-tools: Bash, WebSearch, ...
---
```

(The `name:` field is implicit from the filename in commands.)

### B. Reconcile inject-protocol Tier 2 with the v0.2.0 MCP server

Current (`hooks/inject-protocol.sh:43-50`):

```
2. **firecrawl-search skill** -- for anything that is not a package
   version (articles, blog posts, Reddit threads, ...). Invoke the
   `firecrawl-search` skill or the `/firecrawl:search` workflow ...
```

Proposed:

```
2. **Plugin-scoped firecrawl MCP** -- when FIRECRAWL_API_KEY is set,
   prefer the bundled mcp__plugin_oracle_firecrawl__* tools. They
   return full rendered-page markdown with the URL preserved.
   Fall back to the firecrawl-search skill when the key is unset.
   Fall back further to Tier 3.
```

### C. Add `firecrawl_interact` to the cost table (or remove from
cost-rethinker reference)

Current (`scripts/cost-table.json:20-71`): ten tool entries, no
`firecrawl_interact`.

Proposed: add

```
"mcp__plugin_oracle_firecrawl__firecrawl_interact": {
  "credits_per_call": 5,
  "scales_with": "fixed",
  "notes": "Browser interaction; estimated 5 credits per session-minute, conservative"
}
```

Or remove the row from `cost-rethinker.md:64`.

### D. Fix the README count drift

Current (`README.md:14-16`):

```
Two hooks plus three slash commands plus four subagents plus three
auto-triggering knowledge skills, all driving one rule:
```

Proposed:

```
Four hooks plus five slash commands plus five subagents plus three
auto-triggering knowledge skills, all driving one rule:
```

And update the Components section at `README.md:37-135` accordingly:
add `/oracle:setup`, `/oracle:budget`, the two firecrawl hooks, and
the `cost-rethinker` agent.

### E. Tighten per-silo firecrawl tool grants

Current `forum-anthropologist.md:6` grants all ten MCP tools.
The silo's job is to read forum threads. The minimal grant is
`firecrawl_search` + `firecrawl_scrape` + `firecrawl_map`. Drop
`firecrawl_extract`, `firecrawl_crawl`, `firecrawl_check_crawl_status`,
`firecrawl_batch_scrape`, `firecrawl_check_batch_status`,
`firecrawl_agent`, `firecrawl_agent_status` from this silo. Same
tightening pattern for canon-reader (does not need `firecrawl_agent`)
and issue-investigator (does not need `firecrawl_crawl` /
`firecrawl_agent`). The github-archivist legitimately uses the broader
surface for non-GitHub forges and downstream-usage discovery; keep its
grants.

This shifts cost discipline upstream into the harness rather than
relying on the cost-rethinker agent to catch it after the fact.

---

Read-only audit complete. No files modified.
