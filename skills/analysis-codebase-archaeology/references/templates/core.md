# Core Archaeology Templates

These templates are the base output format for all codebase archaeology. They
are always used regardless of objective. Lens-specific templates ADD fields or
modify emphasis but never replace these.

Every field is mandatory. If a field does not apply, write "N/A — [reason]"
rather than omitting it. Silent omission is how analysis gaps hide.


## BUSINESS RULE

```
RULE_ID:           [module].[function/method].[sequential_number]
DESCRIPTION:       [Plain English — what domain decision does this encode?]
CATEGORY:          [VALIDATION | CALCULATION | BRANCHING | MAPPING |
                    DEFAULTING | SEQUENCING | ACCESS_CONTROL | STATE_TRANSITION]
TRIGGER:           [What condition activates this rule?]
INPUTS:            [Data read by this rule, with types]
LOGIC:             [Pseudocode or decision tree — never raw source syntax]
OUTPUT_EFFECT:     [What changes — data mutation, flow control, side effect?]
PRECISION:         [Rounding, truncation, type coercion behavior]
EDGE_CASES:        [Nulls, zeros, boundary values, empty collections, overflows]
CONFIDENCE:        [HIGH | MEDIUM | LOW — with justification]
EVIDENCE:          [file:line references]
IMPLICIT:          [YES | NO — is this rule documented anywhere outside code?]
DEPENDS_ON_RULES:  [RULE_IDs this rule assumes have already executed]
SIDE_EFFECTS:      [External-facing effects: DB writes, API calls, events]
```


## DATA FLOW

```
FLOW_ID:           [entry_point].[sequential_number]
DESCRIPTION:       [What does this flow accomplish in domain terms?]
SOURCE:            [Where data originates — table.column, API endpoint,
                    file format, env var name]
TRANSFORMATIONS:   [Ordered list of operations applied to the data]
  1. [operation] — [what changes, what is preserved]
  2. ...
INTERMEDIATE_STATE:[Variables/storage that hold partial results mid-flow]
SINK:              [Where data lands — same specificity as SOURCE]
LINEAGE:           [output_field <- input_field(s) with transformation notes]
CROSSES_BOUNDARIES:[YES | NO — does this flow span module/service boundaries?]
ORDER_DEPENDENT:   [YES | NO — does correctness depend on execution sequence?]
ERROR_BEHAVIOR:    [What happens if any step fails? Silent? Retry? Propagate?]
EVIDENCE:          [file:line references for each transformation step]
```


## DEPENDENCY

```
DEP_ID:            [dependent_module]->[dependency].[sequential_number]
TYPE:              [EXPLICIT | IMPLICIT | TEMPORAL | ENVIRONMENTAL]
DIRECTION:         [AFFERENT | EFFERENT]
SOURCE_MODULE:     [Who depends?]
TARGET:            [What is depended upon?]
COUPLING:          [HARD | SOFT | CONVENTIONAL]
FAILURE_MODE:      [What happens if this dependency is unavailable?]
RUNTIME_RESOLVED:  [YES | NO — is this resolved at compile time or runtime?]
EVIDENCE:          [file:line references]
```


## COMPONENT SUMMARY

```
COMPONENT_ID:      [Fully qualified module/class/service name]
PURPOSE:           [One sentence — what domain function does this serve?]
ENTRY_POINTS:      [How is this component invoked?]
BUSINESS_RULES:    [Count and list of RULE_IDs contained]
DATA_FLOWS:        [Count and list of FLOW_IDs passing through]
AFFERENT_COUPLING: [Count — who depends on me?]
EFFERENT_COUPLING: [Count — who do I depend on?]
SHARED_STATE:      [Mutable state this component reads or writes]
BLAST_RADIUS:      [HIGH | MEDIUM | LOW — impact of changes here]
COMPREHENSION_COST:[HIGH | MEDIUM | LOW — effort to understand fully]
TEST_COVERAGE:     [AUTOMATED | MANUAL | NONE — with notes]
INVARIANT_DENSITY: [HIGH | MEDIUM | LOW — business rules per LOC]
TECH_DEBT_PATTERNS:[List of anti-patterns identified]
CHANGE_RISK:       [HIGH | MEDIUM | LOW — composite assessment]
NOTES:             [Anything that doesn't fit above but matters]
```


## ARCHAEOLOGY REPORT (top-level summary)

```
REPORT_SCOPE:      [What was analyzed — repo, directory, module, file set]
ANALYSIS_DATE:     [When this analysis was performed]
ANALYSIS_LENS:     [Which lens was applied — GENERAL | MIGRATION | ARCHITECTURE
                    | RISK | DOCUMENTATION | TEST_STRATEGY | DECOMPOSITION | DEBT]
LANGUAGE(S):       [Languages encountered, with approximate LOC per language]
FRAMEWORK(S):      [Frameworks/platforms detected]

STRUCTURAL_OVERVIEW:
  ENTRY_POINTS:    [Total count with list]
  COMPONENTS:      [Total count with brief taxonomy]
  DEAD_CODE:       [Percentage estimate and locations]
  SHARED_STATE:    [Count of shared mutable state instances]

BUSINESS_RULES:
  TOTAL_COUNT:     [Number of rules extracted]
  BY_CATEGORY:     [Breakdown by CATEGORY]
  HIGH_CONFIDENCE: [Count]
  LOW_CONFIDENCE:  [Count — these need human review]
  IMPLICIT_COUNT:  [Rules with no documentation outside code]

DATA_FLOWS:
  TOTAL_COUNT:     [Number of flows traced]
  CROSS_BOUNDARY:  [Flows that span module boundaries]
  ORDER_DEPENDENT: [Flows sensitive to execution order]

DEPENDENCIES:
  EXPLICIT:        [Count]
  IMPLICIT:        [Count — these are the dangerous ones]
  TEMPORAL:        [Count]
  HARD_COUPLED:    [Count — will break on change]

RISK_ASSESSMENT:
  HIGHEST_RISK:    [Top 3 components by CHANGE_RISK, with reasoning]
  HIDDEN_COMPLEXITY:[Components that look simple but aren't]
  RECOMMENDED_REVIEW:[Areas where CONFIDENCE is LOW and BLAST_RADIUS is HIGH]

KNOWN_UNKNOWNS:
  [Explicitly list what you could NOT determine and why.
   Incomplete analysis is fine. Unacknowledged gaps are not.]

LENS_SPECIFIC:     [Additional findings from the applied lens — see lens
                    template for structure]
```
