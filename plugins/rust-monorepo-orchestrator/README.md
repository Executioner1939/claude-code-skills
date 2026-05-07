# rust-monorepo-orchestrator

Methodology-first multi-agent refactoring orchestrator for monorepos.

The premise: Claude Code is excellent at small, local code work. It falls apart on monorepo-scale refactoring because there is no good way for the harness to coordinate dozens of subagents drilling the same architecture from different angles, generating consistent rules, and applying remediations in parallel without colliding.

This plugin is the missing coordination layer. It does not ship architecture rules. It ships the **machinery** that authors architecture rules per project, then runs them through parallel waves of isolated-worktree workers.

## Status

**M1 (this version, 0.1.0):** plugin scaffold, methodology skills, templates, `/init` command. Single-shot stack discovery and target-standard capture from a reference repo. No refactoring yet.

**M2 (planned):** `/audit-domain` -- drill one domain top-to-bottom, document violations, author project-specific ast-grep rules.

**M3 (planned):** `/plan-refactor` -- convert violations into a sequenced ticket DAG. `/run-wave` -- parallel implementation wave with claim-lock concurrency, automerge on verifier-pass, dead-letter on failure.

## Why filesystem (not Agent Teams)

The experimental `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` primitive ships a built-in mailbox / shared task list / file-locking primitive. We deliberately do not use it. The filesystem-based inbox is:

- **Debuggable**: every ticket and handoff is markdown a human can read in `cat`.
- **Auditable**: full history is in git diff.
- **Portable**: works on any Claude Code version.
- **Composable with existing tooling**: ast-grep, ripgrep, jq, your editor.

If the native primitive matures, swap-in is one well-defined change to `scripts/claim.sh` and the orchestrator agent.

## Conventions

This plugin follows skunkworks conventions:

- Workflow commands in `commands/` are `disable-model-invocation: true`. You invoke; Claude does not auto-trigger them.
- Subagents in `agents/` use `memory: project` and declare their auto-loaded skills via the `skills:` frontmatter list.
- Every multi-agent chain ends with `HANDOFF: <absolute path>` per the orchestration-protocol skill. Orchestrators halt on missing handoffs.
- Every claim about a violation cites `file:line`. Unanchored claims are not allowed.
- No emojis anywhere.
- Audit outputs follow Tier-1 baseline + Tier-2 dated history.

## Layout

```
rust-monorepo-orchestrator/
├── .claude-plugin/plugin.json
├── README.md
├── commands/                       # /init, /audit-domain, /plan-refactor, /run-wave, /status, /replay, /sweep-rules
├── agents/                         # stack-detective, reference-ingester, domain-cartographer, violation-hunter,
│                                   # rule-author, refactor-planner, wave-orchestrator, ticket-implementer, verifier
├── skills/
│   ├── orchestration-protocol/     # the inbox/ticket/handoff contract -- auto-loaded by every agent
│   ├── opus-4-7-prompting/         # reusable XML snippets and dispatch discipline -- auto-loaded by every agent
│   └── astgrep-rule-authoring/     # YAML cookbook for writing rules per project
├── hooks/hooks.json                # SessionStart context injection; PostToolUse registry refresh; SubagentStop activity log
├── templates/                      # ticket.md, result.md, HANDOFF.md, PLAN.md
└── scripts/                        # claim.sh, registry-refresh.sh, automerge.sh, init.sh
```

## Output layout (in your monorepo)

```
<your-repo>/.refactor/
├── stack.json                      # /init output: detected framework, deps, conventions
├── standard.md                     # /init output: target architecture standard (from reference repo, if provided)
├── handoffs/<workflow>-<run-id>/   # phase-NN-from-to.md handoff files
├── domains/<domain>/
│   ├── violations.md               # /audit-domain output
│   ├── PLAN.md                     # /plan-refactor output
│   └── tests.json                  # tests-first per Opus 4.7 long-horizon recipe
├── inbox/<domain>/
│   ├── _registry.md                # orchestrator-maintained index
│   ├── pending/T-NNN.md
│   ├── claimed/T-NNN.md
│   ├── done/T-NNN.md
│   └── failed/T-NNN.md
├── dead-letter/                    # exhausted retries
├── rules/<domain>/*.yml            # ast-grep rules authored per project
└── sgconfig.yml                    # merged across domains
```

## Install

```
/plugin marketplace add Executioner1939/claude-code-skills
/plugin install rust-monorepo-orchestrator@skunkworks
```

## License

MIT.
