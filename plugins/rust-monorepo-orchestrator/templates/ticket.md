---
id: T-NNN
domain: <domain>
created: <ISO8601>
status: pending
depends_on: []
allowed_paths: []
claimed_by: null
claimed_at: null
attempts: 0
max_attempts: 3
isolation: worktree
worker_model: claude-sonnet-4-6
---

## objective

One paragraph. Imperative voice. The four-element subagent contract starts here -- this is the worker's reason to exist. Reference the violation file:line that motivated this ticket. State the desired end-state, not the steps to get there.

## inputs

- target_path: { type: path, value: <absolute-path> }
- violation_id: { type: string, value: <V-NNN> }
- rule_id: { type: string, value: <ast-grep-rule-id> }
- standard: { type: path, value: <scope>/.refactor/standard.md }

## context

- path: ${CLAUDE_PLUGIN_ROOT}/skills/orchestration-protocol/SKILL.md
  why: ticket lifecycle, claim semantics, RESULT.md contract
  do_not_re_derive: true
- path: ${CLAUDE_PLUGIN_ROOT}/skills/opus-4-7-prompting/SKILL.md
  why: prompting discipline (parallel tool use, investigate-before-answering, anti-overengineering)
  do_not_re_derive: true
- path: <scope>/.refactor/domains/<domain>/violations.md
  why: the violation this ticket addresses
  do_not_re_derive: true
- path: <scope>/.refactor/rules/<domain>/<rule-id>.yml
  why: the rule that must pass after the fix
  do_not_re_derive: true

## tools_and_sources

Allowed:
- Read, Glob, Grep
- Edit, Write (within `allowed_paths` only)
- Bash(cargo:*), Bash(ast-grep:*), Bash(git:*) for build/test/commit
- skills (auto-loaded): orchestration-protocol, opus-4-7-prompting

Disallowed:
- Agent (workers do not spawn workers)
- Modifications outside `allowed_paths`

## boundaries

must:
  - work only inside the assigned worktree (already created by orchestrator)
  - touch only files in `allowed_paths`
  - run the listed acceptance checks before yielding
  - commit the change to the worker branch with message: `ticket: T-NNN -- <one-line summary>`
  - write `<ticket-id>-RESULT.md` at the worktree root before yielding
  - print `HANDOFF: <absolute path of RESULT.md>` as the final line

must_not:
  - modify any file outside `allowed_paths`
  - add new dependencies to Cargo.toml without explicit allowance
  - remove or weaken existing tests to make acceptance pass
  - skip clippy / ast-grep checks
  - generate documentation, comments, or formatting beyond what the fix requires

## out_of_scope

- fixing related violations not listed in `inputs.violation_id`
- refactoring beyond the immediate fix
- updating downstream consumers (those become their own tickets if needed)
- merging the worker branch (the orchestrator does that)

## acceptance

Verifiable; each item is a command the verifier re-runs:

- `ast-grep scan -c sgconfig.yml --rule rules/<domain>/<rule-id>.yml --error` exits 0
- `cargo test -p <crate>` exits 0
- `cargo clippy -p <crate> -- -D warnings` exits 0
- no new `unwrap()` / `expect()` introduced (rule: `domain-no-unwrap`)
- `FILES_TOUCHED` is a subset of `allowed_paths`

## output_format

RESULT.md sections in order:
- SUMMARY (one paragraph; reference the objective)
- FILES_TOUCHED (list of paths with create/modify/delete)
- TESTS_RUN (list of commands with PASS/FAIL/SKIPPED)
- RULES_PASSED (list of rule-ids with one-line outcomes)
- FOLLOW_UPS (checkboxes for things noticed but not fixed)

Final line of output: `HANDOFF: <absolute path of RESULT.md>`.

## handoff

write_to: <worktree-root>/T-NNN-RESULT.md
final_line: HANDOFF: <absolute path>
