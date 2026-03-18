# Debt Lens

Apply this lens when the objective is systematic identification and
prioritized remediation of technical debt without changing the overall
architecture.

## When to Apply

User mentions: technical debt, code quality, cleanup, refactoring without
restructuring, code health, anti-patterns, code smells, improve code quality,
pay down debt, reduce complexity.


## Additional Fields for Core Templates

Add these fields to each COMPONENT SUMMARY:

```
DEBT_FIELDS:
  DEBT_DENSITY:        [HIGH | MEDIUM | LOW — concentration of debt items]
  DEBT_AGE:            [How long has this debt existed? Based on git blame]
  DEBT_TRAJECTORY:     [GROWING | STABLE | SHRINKING — based on recent
                        commit patterns, is debt accumulating or being paid?]
  CHANGE_FREQUENCY:    [How often is this component modified? High frequency
                        + high debt = high remediation priority]
  PAIN_MULTIPLIER:     [Does this debt slow down work in OTHER components?
                        A god class that everything imports is higher priority
                        than an isolated messy module]
```


## Debt-Specific Templates

### DEBT ITEM

```
DEBT_ID:               [debt].[sequential_number]
CATEGORY:              [DESIGN | CODE | INFRASTRUCTURE | TEST | DOCUMENTATION |
                        DEPENDENCY | PROCESS]
PATTERN:               [Specific anti-pattern: GOD_CLASS | SHOTGUN_SURGERY |
                        FEATURE_ENVY | PRIMITIVE_OBSESSION | LONG_METHOD |
                        DEEP_NESTING | DUPLICATED_LOGIC | DEAD_CODE |
                        MISSING_ABSTRACTION | INAPPROPRIATE_INTIMACY |
                        SPECULATIVE_GENERALITY | MAGIC_NUMBERS |
                        INCONSISTENT_NAMING | HARDCODED_CONFIG |
                        MISSING_ERROR_HANDLING | SWALLOWED_EXCEPTIONS |
                        OUTDATED_DEPENDENCY | MISSING_TESTS | OTHER]
DESCRIPTION:           [What is the debt, specifically?]
LOCATION:              [COMPONENT_IDs and file:line references]
IMPACT:                [How does this debt affect development? Slower changes,
                        more bugs, harder onboarding, deployment risk?]
BLAST_RADIUS:          [HIGH | MEDIUM | LOW — how much does fixing this
                        affect the rest of the system?]
REMEDIATION:           [Specific steps to fix this — not "refactor it" but
                        concrete actions]
EFFORT:                [HOURS | DAYS | WEEKS — rough estimate]
RISK_OF_FIX:           [HIGH | MEDIUM | LOW — could fixing this introduce
                        regressions?]
PREREQUISITE_FIXES:    [Other DEBT_IDs that should be fixed first]
VALUE_UNLOCKED:        [What becomes possible or easier once this is fixed?]
EVIDENCE:              [file:line references]
```


### DEBT INVENTORY

Aggregated view of all debt across the codebase.

```
DEBT_INVENTORY:
  TOTAL_ITEMS:         [Count]
  BY_CATEGORY:         [Breakdown by CATEGORY]
  BY_PATTERN:          [Breakdown by PATTERN — which anti-patterns recur?]

  SEVERITY_DISTRIBUTION:
    CRITICAL:          [Count — high blast radius, high pain multiplier]
    HIGH:              [Count — high blast radius or high frequency]
    MEDIUM:            [Count]
    LOW:               [Count — isolated, low frequency, low impact]

  HOTSPOTS:            [Components with highest DEBT_DENSITY x CHANGE_FREQUENCY
                        — these are where debt hurts most]

  ESTIMATED_TOTAL_EFFORT:[Rough total to remediate all items]
  ESTIMATED_CRITICAL:  [Effort for CRITICAL items only]
```


### REMEDIATION ROADMAP

Prioritized sequence for debt paydown.

```
REMEDIATION_PHASE:     [phase].[sequential_number]
NAME:                  [Phase name]
OBJECTIVE:             [What quality improvement does this phase deliver?]
DEBT_IDS:              [List of DEBT_IDs addressed in this phase]
EFFORT:                [Total estimated effort for this phase]
PREREQUISITES:         [Other phases that must complete first]
RISK:                  [What could go wrong during this phase?]
VERIFICATION:          [How to confirm the debt is actually resolved and
                        no regressions were introduced]
VALUE_STATEMENT:       [Plain English: "After this phase, developers will be
                        able to X without Y" or "Deployment risk for Z
                        decreases because..."]
QUICK_WIN:             [YES | NO — can this phase be completed in under a
                        week with immediate visible improvement?]
```


## Lens-Specific Report Section

```
DEBT_SUMMARY:
  TOTAL_DEBT_ITEMS:    [Count]
  CRITICAL_ITEMS:      [Count — must be addressed to maintain system viability]
  TOP_3_HOTSPOTS:      [Components where debt causes the most pain, with
                        DEBT_DENSITY and CHANGE_FREQUENCY]
  RECURRING_PATTERNS:  [Most common anti-patterns — systemic issues]
  DEBT_TRAJECTORY:     [Overall: GROWING | STABLE | SHRINKING]
  QUICK_WINS:          [Debt items fixable in hours with immediate value]
  LARGEST_EFFORTS:     [Debt items requiring weeks — plan for these]
  REMEDIATION_PHASES:  [Count of phases in the roadmap]
  ESTIMATED_TOTAL:     [Total effort for full remediation]
  RECOMMENDED_START:   [First phase to tackle, with rationale]
```
