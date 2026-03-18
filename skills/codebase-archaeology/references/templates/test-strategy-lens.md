# Test Strategy Lens

Apply this lens when the objective is building a testing approach based on
discovered business rules and risk profiles — characterization tests for
untested code, behavioral parity tests for migrations, or coverage strategies.

## When to Apply

User mentions: test strategy, test plan, characterization tests, behavioral
tests, test coverage, golden master testing, regression suite, parity tests,
approval tests, what should I test, testing approach.


## Additional Fields for Core Templates

Add these fields to each BUSINESS RULE extracted:

```
TEST_FIELDS:
  CURRENT_COVERAGE:    [AUTOMATED | MANUAL | NONE — is this rule tested today?]
  TEST_REFERENCES:     [file:line of existing tests, if any]
  TESTABILITY:         [EASY | MODERATE | HARD — how difficult is it to test
                        this rule in isolation?]
  TESTABILITY_BLOCKERS:[What prevents easy testing? Global state, external
                        service, database dependency, time sensitivity,
                        non-deterministic input]
  GOLDEN_MASTER_VIABLE:[YES | NO — can you capture current output as a
                        baseline for comparison testing?]
  INPUT_SPACE:         [How large is the input domain? Enumerate key
                        partitions: valid ranges, boundary values, null/empty,
                        error conditions]
  PRIORITY:            [CRITICAL | HIGH | MEDIUM | LOW — based on
                        BLAST_RADIUS x CONFIDENCE inverse. High blast +
                        low confidence = critical test priority]
```


## Test-Specific Templates

### TEST CASE SPECIFICATION

Derived from each BUSINESS RULE. One or more test cases per rule.

```
TEST_ID:               [test].[RULE_ID].[sequential_number]
SOURCE_RULE:           [RULE_ID this test verifies]
DESCRIPTION:           [What behavior is being verified, in plain English]
CATEGORY:              [CHARACTERIZATION | BEHAVIORAL_PARITY | REGRESSION |
                        BOUNDARY | ERROR_HANDLING | SMOKE]
PRECONDITIONS:         [State that must exist before test runs — database
                        records, config values, prior operations]
INPUT:                 [Specific input values with types]
EXPECTED_OUTPUT:       [Exact expected result, including precision, type,
                        and format]
BOUNDARY_VARIANT:      [If testing a boundary: which boundary, which side]
ERROR_VARIANT:         [If testing error handling: which error, expected
                        recovery behavior]
ISOLATION_STRATEGY:    [How to isolate this test: mock, stub, fake, in-memory
                        database, test container, or requires real dependency]
DETERMINISM:           [DETERMINISTIC | NON_DETERMINISTIC — if non-deterministic,
                        what makes it so and how to control it]
AUTOMATABLE:           [YES | NO — if no, describe the manual verification]
EXECUTION_TIME:        [FAST (<1s) | MEDIUM (<30s) | SLOW (>30s)]
```


### COVERAGE MAP

Aggregated view of test coverage across business rules.

```
COVERAGE_MAP:
  TOTAL_RULES:         [Count of extracted business rules]
  CURRENTLY_TESTED:    [Count with existing automated tests]
  UNTESTED_CRITICAL:   [Count of CRITICAL priority rules with no tests]
  UNTESTED_HIGH:       [Count of HIGH priority rules with no tests]

  BY_CATEGORY:
    VALIDATION:        [tested/total]
    CALCULATION:       [tested/total]
    BRANCHING:         [tested/total]
    MAPPING:           [tested/total]
    DEFAULTING:        [tested/total]
    SEQUENCING:        [tested/total]
    ACCESS_CONTROL:    [tested/total]
    STATE_TRANSITION:  [tested/total]

  TESTABILITY_BARRIERS:
    GLOBAL_STATE:      [Count of rules blocked by global state]
    EXTERNAL_DEPS:     [Count blocked by external service dependencies]
    DATABASE_COUPLING: [Count requiring database for testing]
    TIME_SENSITIVITY:  [Count dependent on system clock]
    NON_DETERMINISTIC: [Count with non-deterministic behavior]
```


### TEST EXECUTION PLAN

Recommended order and grouping for test implementation.

```
PHASE_ID:              [test_phase].[sequential_number]
NAME:                  [Phase name]
OBJECTIVE:             [What coverage does this phase add?]
TEST_IDS:              [List of TEST_IDs in this phase]
INFRASTRUCTURE_NEEDED: [Test doubles, containers, fixtures, data generators]
ESTIMATED_EFFORT:      [DAYS — rough implementation estimate]
PREREQUISITE_PHASES:   [Other phases that must complete first]
VALUE_DELIVERED:       [What risk is reduced by completing this phase?]
```


## Lens-Specific Report Section

```
TEST_STRATEGY_SUMMARY:
  COVERAGE_CURRENT:        [Percentage of rules with existing tests]
  COVERAGE_TARGET:         [Recommended target with rationale]
  CRITICAL_GAPS:           [Rules with HIGH blast radius and NO coverage]
  TEST_CASES_GENERATED:    [Total TEST_IDs produced]
  AUTOMATABLE_PERCENTAGE:  [Percentage that can be automated]
  INFRASTRUCTURE_REQUIRED: [Test doubles, containers, fixtures needed]
  RECOMMENDED_FRAMEWORK:   [Testing framework suggestions based on codebase]
  ESTIMATED_TOTAL_EFFORT:  [Rough total to implement full test suite]
  QUICK_WINS:              [Tests that are easy to write and high value]
  HARDEST_TO_TEST:         [Components with worst testability scores]
```
