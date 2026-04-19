# Migration Lens

Apply this lens when the objective is moving a codebase from one language,
runtime, or framework to another. This lens adds fields to core templates and
introduces migration-specific output formats.

## When to Apply

User mentions: language migration, rewrite in X, port to Y, convert from A to
B, framework migration, runtime change, platform migration.


## Additional Fields for Core Templates

Add these fields to each BUSINESS RULE extracted:

```
MIGRATION_FIELDS:
  TYPE_MAPPING:        [How do the types in this rule map to the target
                        language? Flag any that have no direct equivalent]
  PRECISION_PARITY:    [Will the target language produce identical results
                        for this calculation? Flag float/decimal differences,
                        integer overflow behavior, string handling differences]
  IDIOM_TRANSLATION:   [Does this logic rely on a language-specific idiom?
                        e.g., COBOL PERFORM VARYING, Python list comprehension,
                        Ruby method_missing, C pointer arithmetic]
  STDLIB_DEPENDENCY:   [Does this rule use standard library functions that
                        behave differently in the target? e.g., date parsing,
                        string sorting, regex engines, math rounding modes]
  CONCURRENCY_MODEL:   [Does this rule assume a specific concurrency model?
                        Single-threaded, thread-per-request, async/await,
                        actor model, coroutines]
```

Add these fields to each DATA FLOW extracted:

```
MIGRATION_FIELDS:
  SERIALIZATION_FORMAT:[Wire format / file format — does the target ecosystem
                        have native support? JSON, XML, protobuf, CSV,
                        fixed-width, EBCDIC, binary packed]
  ENCODING_SENSITIVITY:[Character encoding assumptions that may differ:
                        ASCII vs UTF-8, code page, endianness, line endings]
  IO_MODEL:            [Sync/async, buffered/unbuffered, stream/batch —
                        does the target handle I/O differently?]
```

Add these fields to each DEPENDENCY extracted:

```
MIGRATION_FIELDS:
  TARGET_EQUIVALENT:   [Equivalent library/service in target ecosystem,
                        or NONE if no equivalent exists]
  BEHAVIORAL_DIFF:     [Known behavioral differences between source and
                        target equivalents — even subtle ones]
  WRAPPER_NEEDED:      [YES | NO — does the target equivalent need an
                        adapter to match the source interface?]
```


## Migration-Specific Templates

### TYPE MAPPING REGISTER

One per codebase. Catalogs every type used and its target equivalent.

```
TYPE_MAP_ID:           [source_type]->[target_type].[sequential_number]
SOURCE_TYPE:           [Type as used in source codebase]
TARGET_TYPE:           [Equivalent in target language]
FIDELITY:              [EXACT | APPROXIMATE | LOSSY | NO_EQUIVALENT]
BEHAVIORAL_DIFFERENCE: [What differs? Precision, range, null handling,
                        comparison semantics, default values]
OCCURRENCES:           [How many rules/flows use this type?]
MITIGATION:            [How to handle the difference — wrapper, assertion,
                        custom type, documentation]
EVIDENCE:              [file:line examples of usage]
```


### ECOSYSTEM MAPPING

Catalogs library/framework equivalents.

```
ECOSYSTEM_MAP_ID:      [source_lib]->[target_lib].[sequential_number]
SOURCE:                [Library, framework, or platform feature]
TARGET:                [Equivalent in target ecosystem]
COVERAGE:              [FULL | PARTIAL | NONE — how much of the source
                        API surface does the target cover?]
API_DRIFT:             [Method/function names that differ, parameters that
                        changed, return types that don't match]
BEHAVIORAL_PARITY:     [Known cases where same inputs produce different
                        outputs between source and target]
MIGRATION_EFFORT:      [HIGH | MEDIUM | LOW]
```


### PRECISION AUDIT

Critical for financial, scientific, or any calculation-heavy code.

```
PRECISION_ID:          [module].[function].[sequential_number]
CALCULATION:           [Description of the calculation]
SOURCE_PRECISION:      [How the source language handles this: decimal type,
                        float width, rounding mode, truncation behavior]
TARGET_PRECISION:      [How the target language handles the same]
DRIFT_RISK:            [Will results differ? By how much? Under what inputs?]
TEST_VECTOR:           [Specific input values that expose precision differences]
EVIDENCE:              [file:line reference]
```


## Lens-Specific Report Section

Add to the LENS_SPECIFIC field of the ARCHAEOLOGY REPORT:

```
MIGRATION_SUMMARY:
  SOURCE_LANGUAGE:     [Language(s) and version(s)]
  TARGET_LANGUAGE:     [Language(s) and version(s)]
  TYPE_MAPPINGS:       [Total count, with LOSSY and NO_EQUIVALENT highlighted]
  ECOSYSTEM_GAPS:      [Libraries with no target equivalent]
  PRECISION_RISKS:     [Count of calculations with DRIFT_RISK]
  IDIOM_HOTSPOTS:      [Code heavily reliant on source-specific idioms]
  CONCURRENCY_SHIFT:   [Does the target require a different concurrency model?]
  ESTIMATED_MECHANICAL:[Percentage of code that maps mechanically]
  ESTIMATED_REDESIGN:  [Percentage requiring non-trivial redesign]
```
