# Transformation Plan Templates

These templates are used by the transformation strategist agent to produce
actionable plans from archaeology output. They are separate from archaeology
templates because they describe WHAT TO DO, not WHAT EXISTS.


## GAP ANALYSIS

Produced before any planning. Validates archaeology completeness.

```
OBJECTIVE:              [User's stated transformation objective]
ARCHAEOLOGY_RECEIVED:   [List of artifact types received]
ARCHAEOLOGY_MISSING:    [List of artifact types needed but not provided]
LENS_APPLIED:           [Which lens was used in the archaeology]
LENS_APPROPRIATE:       [YES | NO — is the lens correct for this objective?
                         If NO, recommend re-analysis with correct lens]
COVERAGE_ASSESSMENT:
  COMPONENTS_ANALYZED:  [X of Y total components have archaeology]
  RULES_CONFIDENCE:     [% at HIGH | % at MEDIUM | % at LOW]
  FLOWS_COMPLETE:       [X of Y flows traced end-to-end]
  DEPS_MAPPED:          [X of Y dependencies classified]
BLOCKING_GAPS:          [Gaps that prevent planning — list with reasons]
ASSUMPTION_GAPS:        [Gaps you will plan around with stated assumptions]
KNOWN_UNKNOWNS_IMPACT: [Which KNOWN UNKNOWNS from archaeology affect this
                         objective, and how?]
RECOMMENDATION:         [PROCEED | PROCEED WITH CAVEATS | REANALYZE FIRST]
```


## ELEMENT MAPPING

One per archaeology artifact (rule, flow, dependency, component).

```
ELEMENT_ID:             [RULE_ID, FLOW_ID, DEP_ID, or COMPONENT_ID]
ELEMENT_TYPE:           [RULE | FLOW | DEPENDENCY | COMPONENT]
CURRENT_LOCATION:       [Where it lives now — module, layer, service]
MAPPING_CLASS:          [NATURAL_FIT | FORCED_FIT | RESISTS_MAPPING |
                         INVARIANT | ELIMINATED]
TARGET_LOCATION:        [Where it belongs in the target model]
TRANSFORMATION_NEEDED:  [Specific changes required]
DECISIONS_REQUIRED:     [Choices a human must make — not automatable]
RISK_LEVEL:             [HIGH | MEDIUM | LOW]
DEPENDS_ON_MAPPINGS:    [Other ELEMENT_IDs that must be resolved first]
NOTES:                  [Friction points, ambiguities, alternatives]
```


## TRANSFORMATION SEQUENCE

Ordered phases for execution.

```
PHASE_NUMBER:           [Sequential phase identifier]
PHASE_NAME:             [Descriptive name]
OBJECTIVE:              [What this phase accomplishes]
ELEMENTS_TRANSFORMED:   [List of ELEMENT_IDs addressed in this phase]
PRECONDITIONS:          [What must be true before this phase starts]
INTERIM_STATE:          [Description of the system state after this phase]
COEXISTENCE_STRATEGY:   [How old and new interact — adapters, facades,
                         feature flags, strangler pattern, ACL]
INVARIANTS:             [What must remain true throughout this phase]
VERIFICATION_CRITERIA:  [How to confirm this phase succeeded]
ROLLBACK_STRATEGY:      [How to revert — or why you can't]
ESTIMATED_COMPLEXITY:   [HIGH | MEDIUM | LOW — relative to other phases]
HARD_PROBLEMS:          [Specific difficulties this phase surfaces]
```


## VERIFICATION ITEM

Derived from archaeology business rules and data flows.

```
VERIFY_ID:              [verification].[sequential_number]
SOURCE_ARTIFACT:        [RULE_ID or FLOW_ID this verification derives from]
TYPE:                   [BEHAVIORAL_PARITY | DATA_FLOW | REGRESSION | SMOKE]
DESCRIPTION:            [What is being verified in plain English]
INPUT_CONDITIONS:       [Setup / preconditions / test data]
EXPECTED_OUTCOME:       [Exact expected result, including precision]
EDGE_CASES_COVERED:     [Which boundary conditions this exercises]
PHASE_APPLICABLE:       [Which PHASE_NUMBER(s) this applies to]
PRIORITY:               [MUST_PASS | SHOULD_PASS | BEST_EFFORT]
AUTOMATABLE:            [YES | NO — if no, describe manual process]
HUMAN_REVIEW_NEEDED:    [YES | NO — for LOW confidence source artifacts]
```


## RISK ENTRY

```
RISK_ID:                [risk].[sequential_number]
CATEGORY:               [TECHNICAL | PROCESS | ORGANIZATIONAL | UNKNOWN]
DESCRIPTION:            [What could go wrong]
TRIGGER:                [What causes this risk to materialize]
PHASE_RELEVANT:         [Which PHASE_NUMBER(s) this risk applies to]
IMPACT:                 [What happens if it materializes — be specific]
LIKELIHOOD:             [HIGH | MEDIUM | LOW]
SEVERITY:               [HIGH | MEDIUM | LOW]
MITIGATION:             [What to do to prevent it]
DETECTION:              [How you will know it happened]
CONTINGENCY:            [What to do if mitigation fails]
SOURCE_EVIDENCE:        [Which archaeology artifacts informed this risk]
```


## TRANSFORMATION PLAN (top-level summary)

```
PLAN_SCOPE:             [What is being transformed]
OBJECTIVE:              [Target state — architecture, language, pattern]
ARCHAEOLOGY_BASIS:      [Reference to archaeology report used as input]
GAP_ASSESSMENT:         [PROCEED | PROCEED WITH CAVEATS | REANALYZE FIRST]

MAPPING_SUMMARY:
  NATURAL_FIT:          [Count and percentage]
  FORCED_FIT:           [Count and percentage]
  RESISTS_MAPPING:      [Count and percentage — the hard problems]
  INVARIANT:            [Count and percentage]
  ELIMINATED:           [Count and percentage]

SEQUENCE_SUMMARY:
  TOTAL_PHASES:         [Count]
  CRITICAL_PATH:        [Phases that cannot be parallelized]
  PARALLELIZABLE:       [Phases that can run concurrently]
  ESTIMATED_COMPLEXITY: [Aggregate assessment]

VERIFICATION_SUMMARY:
  MUST_PASS:            [Count of critical verifications]
  TOTAL_VERIFICATIONS:  [Count]
  AUTOMATABLE:          [Percentage]
  HUMAN_REVIEW_NEEDED:  [Count — plan for these]

RISK_SUMMARY:
  TOTAL_RISKS:          [Count]
  HIGH_SEVERITY:        [Count]
  TOP_3_RISKS:          [Brief description of the three most dangerous]

DECISIONS_REQUIRED:     [Choices a human must make before or during execution]

HARD_TRUTHS:            [Complexity that cannot be shortcut. Timelines that
                         are optimistic. Assumptions that are fragile.
                         State plainly.]
```
