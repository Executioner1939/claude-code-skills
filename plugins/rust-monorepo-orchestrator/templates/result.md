# RESULT -- T-NNN

> Mirror of the ticket. Style mirroring per Anthropic Opus 4.7 prompting docs --
> the verifier and the orchestrator parse this format exactly.

## SUMMARY

One paragraph. What was done. Reference the ticket's `objective` -- the
verifier confirms the SUMMARY addresses it. Do not narrate effort; state
the change in past tense.

## FILES_TOUCHED

- `path/to/file.rs` (created | modified | deleted)
- `path/to/other.rs` (modified)

The verifier confirms this list is a subset of `allowed_paths`. Out-of-scope
edits cause an automatic FAIL with reason `scope-exceeded`.

## TESTS_RUN

- `cargo test -p <crate>` -- PASS
- `cargo clippy -p <crate> -- -D warnings` -- PASS
- `ast-grep scan -c sgconfig.yml --rule rules/<domain>/<rule-id>.yml --error` -- PASS

If FAIL, include the last 10 lines of stderr inline so the verifier and
the orchestrator do not need to re-run to diagnose.

## RULES_PASSED

- `domain-no-infra-import`: 0 hits in `src/domain/orders/decider.rs` (was 1)
- `domain-no-unwrap`: 0 hits (no new violations introduced)

List EVERY rule the ticket's `acceptance` declared, plus any project-wide
sentinel rules that should remain clean.

## FOLLOW_UPS

Things noticed during this work that are out of scope for this ticket but
worth surfacing. The planner converts these into new tickets if the
orchestrator agrees.

- [ ] `application/orders/handler.rs:42` has the same pattern (different file, would be a separate ticket).
- [ ] `decider.rs:88` could be simplified once `domain-no-infra-import` is clean repo-wide.

## HANDOFF

`HANDOFF: <absolute path of this RESULT.md>`

This line is mandatory and must be the final line of output. The orchestrator
halts on missing handoffs.
