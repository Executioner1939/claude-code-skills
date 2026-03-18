# Documentation Lens

Apply this lens when the objective is producing human-readable documentation
from archaeology artifacts — onboarding guides, architecture decision records,
operational runbooks, or living system documentation.

## When to Apply

User mentions: document this, generate documentation, onboarding guide,
architecture docs, system documentation, runbook, operational guide,
explain this codebase, how does this work for a new developer.


## Additional Fields for Core Templates

Add these fields to each BUSINESS RULE extracted:

```
DOCUMENTATION_FIELDS:
  AUDIENCE_LEVEL:      [EXECUTIVE | TECHNICAL_LEAD | DEVELOPER | OPERATOR |
                        NEW_HIRE — who needs to know about this rule?]
  PLAIN_ENGLISH:       [Non-technical explanation suitable for business
                        stakeholders. No code, no jargon]
  HISTORICAL_CONTEXT:  [If determinable from git history or comments: when
                        was this rule introduced? What prompted it?]
  RELATED_RULES:       [RULE_IDs that form a logical group with this one]
  DECISION_RECORD:     [If this rule represents an architectural or business
                        decision: what was decided, why, and what alternatives
                        were rejected (if determinable)?]
```

Add these fields to each COMPONENT SUMMARY:

```
DOCUMENTATION_FIELDS:
  ONE_PARAGRAPH:       [Component explained in one paragraph for a new
                        developer joining the team]
  INTERACTION_NARRATIVE:[How does a request/event flow through this component?
                        Written as a narrative, not a template]
  GOTCHAS:             [Things that will surprise a new developer — implicit
                        assumptions, non-obvious behavior, historical quirks]
  RELATED_COMPONENTS:  [COMPONENT_IDs this one interacts with most, with
                        one-sentence description of each relationship]
```


## Documentation-Specific Templates

### SYSTEM NARRATIVE

A prose document explaining the system for a specific audience. One per
audience level.

```
NARRATIVE_ID:          [narrative].[audience_level]
AUDIENCE:              [Who is this written for?]
READING_TIME:          [Estimated minutes]

OVERVIEW:              [What does this system do? 2-3 sentences max]

KEY_CONCEPTS:          [Domain terms someone must understand, each with a
                        one-sentence definition. No more than 10]

HOW_IT_WORKS:          [Narrative walkthrough of the system's primary flow.
                        Written in prose, not templates. Uses domain language.
                        Includes "when X happens, Y does Z" structure]

MAIN_COMPONENTS:       [Each major component with one-paragraph explanation
                        of what it does and why it exists]

DATA_STORY:            [Where does data come from? What happens to it?
                        Where does it end up? Written as a story]

COMMON_OPERATIONS:     [The 3-5 most frequent things someone would do with
                        this system, with step-by-step walkthroughs]

THINGS_TO_KNOW:        [Non-obvious facts, historical decisions, implicit
                        assumptions, and "why is it like this?" answers]
```


### DECISION RECORD

Reconstructed architecture/design decisions from code evidence.

```
DECISION_ID:           [adr].[sequential_number]
TITLE:                 [Short description of the decision]
STATUS:                [ACTIVE | SUPERSEDED | DEPRECATED — based on code evidence]
CONTEXT:               [What situation led to this decision? Reconstructed
                        from code patterns, comments, git history]
DECISION:              [What was decided?]
EVIDENCE:              [Code patterns, comments, git commits that reveal this]
CONSEQUENCES:          [What followed from this decision — positive and negative,
                        as visible in the current codebase]
CONFIDENCE:            [HIGH | MEDIUM | LOW — how certain is this reconstruction?]
```


### ONBOARDING PATH

Recommended reading order for a new developer.

```
ONBOARDING:
  PREREQUISITES:       [What should someone know before reading this codebase?
                        Languages, frameworks, domain concepts]
  READING_ORDER:       [Ordered list of files/modules to read, with a one-
                        sentence description of why each matters]
    1. [file/module] — [why read this first]
    2. ...
  FIRST_TASKS:         [3-5 small, safe tasks a new developer could do to
                        learn the codebase through practice]
  COMMON_MISTAKES:     [Things new developers frequently get wrong]
  WHO_TO_ASK:          [If determinable: knowledge owners per area]
```


## Lens-Specific Report Section

```
DOCUMENTATION_SUMMARY:
  NARRATIVES_PRODUCED: [Count and audience levels covered]
  DECISIONS_RECONSTRUCTED:[Count of architecture decision records]
  DOCUMENTATION_GAPS:  [Areas where existing docs are STALE, MISLEADING,
                        or ABSENT]
  ONBOARDING_ESTIMATE: [Time for a new developer based on current state]
  TRIBAL_KNOWLEDGE:    [Count of IMPLICIT business rules — knowledge that
                        exists only in the code or in people's heads]
  RECOMMENDED_LIVING_DOCS:[What should be maintained as living documentation
                        vs. point-in-time reference?]
```
