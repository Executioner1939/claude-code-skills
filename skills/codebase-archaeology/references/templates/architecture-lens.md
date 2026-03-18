# Architecture Lens

Apply this lens when the objective is reorganizing internal structure toward a
target architectural pattern. This lens adds fields to core templates and
introduces architecture-specific output formats.

## When to Apply

User mentions: hexagonal architecture, ports and adapters, CQRS, event
sourcing, clean architecture, onion architecture, domain-driven design,
modular monolith, layered to X, restructuring, pattern refactoring,
dependency inversion, bounded contexts.


## Additional Fields for Core Templates

Add these fields to each BUSINESS RULE extracted:

```
ARCHITECTURE_FIELDS:
  DOMAIN_PURITY:       [PURE | MIXED | INFRASTRUCTURE — does this rule contain
                        only domain logic, or is it tangled with I/O, framework
                        calls, persistence, or transport concerns?]
  READ_WRITE:          [READ | WRITE | BOTH — does this rule query state,
                        mutate state, or both? Critical for CQRS separation]
  COMMAND_OR_QUERY:    [COMMAND | QUERY | MIXED — could this rule be cleanly
                        expressed as a single command or query?]
  STATE_MUTATION:      [What state does this rule change? Is the mutation
                        the primary purpose or a side effect?]
  EVENT_CANDIDATE:     [YES | NO — could this rule's effect be expressed as
                        a domain event? What would that event be?]
  AGGREGATE_AFFINITY:  [Which aggregate/entity does this rule naturally belong
                        to? Flag rules that span multiple aggregates]
  PORT_CANDIDATE:      [YES | NO — does this rule interact with external
                        concerns through an interface that could become a port?]
```

Add these fields to each DATA FLOW extracted:

```
ARCHITECTURE_FIELDS:
  DIRECTION:           [INBOUND | OUTBOUND | INTERNAL — relative to what would
                        become the domain core]
  ADAPTER_BOUNDARY:    [Where in this flow does the infrastructure/domain
                        boundary naturally fall?]
  PROJECTION_CANDIDATE:[YES | NO — for CQRS: could this flow's read path
                        be served by a dedicated read model/projection?]
  EVENT_FLOW:          [Could this flow be decomposed into event
                        publication and event handling?]
```

Add these fields to each COMPONENT SUMMARY:

```
ARCHITECTURE_FIELDS:
  LAYER_CURRENT:       [Where this component sits now: presentation, application,
                        domain, infrastructure, or MIXED]
  LAYER_TARGET:        [Where it should sit in the target architecture]
  BOUNDARY_VIOLATIONS: [Current dependencies that violate the target's
                        dependency rules — e.g., domain depending on infrastructure]
  SEAM_QUALITY:        [How clean is the boundary around this component?
                        CLEAN (clear interface), LEAKY (some coupling),
                        ENTANGLED (deeply woven into other concerns)]
```


## Architecture-Specific Templates

### BOUNDED CONTEXT MAP

Identifies natural domain boundaries in the codebase.

```
CONTEXT_ID:            [context_name].[sequential_number]
NAME:                  [Descriptive name for this bounded context]
DESCRIPTION:           [What domain concept does this context own?]
COMPONENTS:            [COMPONENT_IDs that belong to this context]
BUSINESS_RULES:        [RULE_IDs owned by this context]
DATA_OWNED:            [Entities, tables, state that this context is
                        authoritative for]
INBOUND_DEPS:          [Other contexts that call into this one]
OUTBOUND_DEPS:         [Other contexts this one calls]
SHARED_KERNEL:         [Data or logic shared with other contexts — these
                        are the hardest boundaries to draw]
CONTEXT_RELATIONSHIP:  [For each connected context: UPSTREAM | DOWNSTREAM |
                        PARTNERSHIP | SHARED_KERNEL | CONFORMIST |
                        ANTICORRUPTION_LAYER_NEEDED]
EXTRACTION_DIFFICULTY: [HIGH | MEDIUM | LOW — how hard is it to isolate
                        this context from the rest?]
EVIDENCE:              [file:line references for boundary indicators]
```


### SEAM ANALYSIS

Identifies natural cut points for restructuring.

```
SEAM_ID:               [module_a]<->[module_b].[sequential_number]
DESCRIPTION:           [What interaction does this seam represent?]
CURRENT_COUPLING:      [How are these modules connected now? Direct call,
                        shared database, shared memory, message passing,
                        file exchange]
COUPLING_STRENGTH:     [HARD | SOFT | CONVENTIONAL]
INTERFACE_SURFACE:     [Methods/functions/endpoints that cross this seam]
DATA_CROSSING:         [What data moves across? Volume? Frequency?]
INVERSION_CANDIDATE:   [YES | NO — can the dependency direction be inverted
                        by introducing an interface/port?]
ASYNC_CANDIDATE:       [YES | NO — can this synchronous coupling become
                        asynchronous via events or messages?]
EXTRACTION_COST:       [HIGH | MEDIUM | LOW — effort to cleanly separate]
EVIDENCE:              [file:line references]
```


### DOMAIN EVENT CATALOG

For CQRS-ES targets, identifies candidate events from existing mutations.

```
EVENT_ID:              [context].[event_name].[sequential_number]
NAME:                  [PastTenseVerb + Noun, e.g., OrderPlaced, PaymentProcessed]
SOURCE_RULE:           [RULE_ID that currently performs this mutation]
TRIGGER:               [What causes this event to occur?]
PAYLOAD:               [Data carried by this event]
SUBSCRIBERS:           [Who currently reacts to this state change? Even if
                        not event-driven today, who reads this data after
                        it changes?]
ORDERING_REQUIREMENTS: [Must this event be processed before/after others?]
IDEMPOTENCY:           [Can this event be safely replayed? What changes?]
EVIDENCE:              [file:line references showing the current mutation]
```


## Lens-Specific Report Section

Add to the LENS_SPECIFIC field of the ARCHAEOLOGY REPORT:

```
ARCHITECTURE_SUMMARY:
  TARGET_PATTERN:      [Hexagonal | CQRS | CQRS-ES | Clean | Modular Monolith
                        | Event-Driven | Custom — as stated by user]
  BOUNDED_CONTEXTS:    [Count identified, with natural vs. forced boundaries]
  SEAMS_IDENTIFIED:    [Count, with INVERSION_CANDIDATE and ASYNC_CANDIDATE
                        breakdown]
  DOMAIN_PURITY:       [Percentage of rules that are PURE domain logic vs.
                        MIXED with infrastructure]
  READ_WRITE_RATIO:    [Percentage of rules that are READ-only vs WRITE vs
                        BOTH — informs CQRS viability]
  EVENT_CANDIDATES:    [Count of domain events identified]
  BOUNDARY_VIOLATIONS: [Count of dependencies that violate target pattern]
  LARGEST_ENTANGLEMENT:[The most tightly coupled area — where restructuring
                        will be hardest]
  QUICK_WINS:          [Components with CLEAN seams and PURE domain logic
                        that can be restructured first]
```
