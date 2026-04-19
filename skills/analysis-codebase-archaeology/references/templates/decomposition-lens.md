# Decomposition Lens

Apply this lens when the objective is extracting services from a monolithic
system, establishing modular boundaries, or planning microservice extraction.

## When to Apply

User mentions: microservices, service extraction, service decomposition,
modular monolith, break apart, split the monolith, bounded contexts,
service boundaries, domain services, API gateway.


## Additional Fields for Core Templates

Add these fields to each BUSINESS RULE extracted:

```
DECOMPOSITION_FIELDS:
  OWNERSHIP_CANDIDATE: [Which service/module would own this rule?]
  CROSS_SERVICE:       [YES | NO — does this rule need data from what would
                        become a different service?]
  CONSISTENCY_REQ:     [STRONG | EVENTUAL | NONE — what consistency guarantee
                        does this rule require for its inputs?]
  TRANSACTION_SCOPE:   [Does this rule participate in a transaction that
                        spans what would become service boundaries?]
```

Add these fields to each DATA FLOW extracted:

```
DECOMPOSITION_FIELDS:
  BOUNDARY_CROSSINGS:  [Count of proposed service boundaries this flow crosses]
  SYNC_REQUIREMENT:    [Must this flow be synchronous end-to-end, or can
                        segments become async?]
  DATA_OWNERSHIP:      [Which proposed service is authoritative for the
                        data in this flow?]
  DUPLICATION_NEEDED:  [Will decomposition require data duplication/projection
                        across services?]
```


## Decomposition-Specific Templates

### SERVICE CANDIDATE

```
SERVICE_ID:            [service_candidate].[sequential_number]
NAME:                  [Proposed service name]
DOMAIN_RESPONSIBILITY: [What business capability does this service own?]
COMPONENTS_INCLUDED:   [COMPONENT_IDs that would move into this service]
RULES_OWNED:           [RULE_IDs this service is authoritative for]
DATA_OWNED:            [Tables, entities, state this service would own]
API_SURFACE:           [Operations this service would expose to others]
INBOUND_DEPENDENCIES:  [Other services that would call this one]
OUTBOUND_DEPENDENCIES: [Other services this one would call]
SHARED_DATA:           [Data currently shared with other candidates that
                        must be resolved — duplicate, API, or event]
EXTRACTION_ORDER:      [Can this be extracted independently, or does it
                        depend on other extractions happening first?]
EXTRACTION_DIFFICULTY: [HIGH | MEDIUM | LOW]
STRANGLER_VIABLE:      [YES | NO — can this be extracted incrementally
                        behind a facade while the monolith still runs?]
```


### DISTRIBUTED TRANSACTION MAP

Identifies transactions that would span service boundaries post-decomposition.

```
DIST_TX_ID:            [dist_tx].[sequential_number]
DESCRIPTION:           [What business operation does this transaction serve?]
CURRENT_SCOPE:         [Tables/state modified in the current single transaction]
SERVICES_INVOLVED:     [SERVICE_IDs that would participate post-decomposition]
CONSISTENCY_REQUIRED:  [STRONG | EVENTUAL — what does the business actually need?]
PATTERN_CANDIDATE:     [SAGA | OUTBOX | TWO_PHASE_COMMIT | COMPENSATING_TX |
                        ACCEPT_INCONSISTENCY]
FAILURE_SCENARIO:      [What happens if step N succeeds but step N+1 fails?]
COMPENSATION_LOGIC:    [How to undo partial work — or why you can't]
EVIDENCE:              [file:line references for current transaction boundaries]
```


### DATA OWNERSHIP RESOLUTION

For shared tables/state that multiple service candidates currently access.

```
OWNERSHIP_ID:          [ownership].[sequential_number]
DATA_ENTITY:           [Table, collection, or state in question]
CURRENT_ACCESSORS:     [COMPONENT_IDs that read or write this data]
PROPOSED_OWNER:        [SERVICE_ID that should own this data]
OTHER_CONSUMERS:       [SERVICE_IDs that need access but won't own it]
ACCESS_PATTERN:        [How do non-owners access it? API call, event-driven
                        projection, data duplication, shared database (anti-pattern)]
MIGRATION_STRATEGY:    [How to move from shared to owned — strangler,
                        dual-write, change data capture, big bang]
RISK:                  [What breaks if this ownership assignment is wrong?]
```


## Lens-Specific Report Section

```
DECOMPOSITION_SUMMARY:
  SERVICE_CANDIDATES:      [Count identified]
  NATURAL_BOUNDARIES:      [Services with clean extraction paths]
  ENTANGLED_BOUNDARIES:    [Services with significant shared state or
                            cross-cutting transactions]
  DISTRIBUTED_TRANSACTIONS:[Count — each one is a complexity multiplier]
  DATA_OWNERSHIP_CONFLICTS:[Count of shared data entities needing resolution]
  RECOMMENDED_EXTRACTION_ORDER:[Ordered list of SERVICE_IDs with rationale]
  STRANGLER_VIABLE_COUNT:  [How many can be extracted incrementally?]
  BIG_BANG_REQUIRED:       [Any extractions that cannot be done incrementally?]
```
