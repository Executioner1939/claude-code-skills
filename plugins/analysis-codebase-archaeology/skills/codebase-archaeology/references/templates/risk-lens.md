# Risk Lens

Apply this lens when the objective is evaluating a codebase for acquisition,
audit, compliance, or general risk assessment. This lens emphasizes liability,
maintainability, key-person risk, and remediation cost.

## When to Apply

User mentions: due diligence, audit, risk assessment, acquisition review,
compliance, code quality assessment, maintainability scoring, technical
liability, codebase evaluation, health check.


## Additional Fields for Core Templates

Add these fields to each BUSINESS RULE extracted:

```
RISK_FIELDS:
  REGULATORY_RELEVANCE:[NONE | POSSIBLE | CONFIRMED — does this rule implement
                        regulatory, compliance, or legal requirements?]
  REGULATION_REF:      [If applicable: GDPR article, SOX section, PCI
                        requirement, industry standard reference]
  CORRECTNESS_RISK:    [What is the business impact if this rule produces
                        wrong results? Financial loss amount, compliance
                        violation, safety risk, reputational damage]
  AUDITABILITY:        [Can the execution of this rule be traced in logs
                        or audit trails? YES | PARTIAL | NO]
  LAST_MODIFIED:       [Git blame date if available — rules untouched for
                        years may indicate abandonment or stability]
  SINGLE_POINT_OWNER:  [Is there evidence only one person understands this?
                        Check git blame concentration]
```

Add these fields to each COMPONENT SUMMARY:

```
RISK_FIELDS:
  BUS_FACTOR:          [How many people have committed to this component
                        in the last 12 months? 1 = critical risk]
  COMMIT_VELOCITY:     [Commits per month over last 12 months — declining
                        velocity may indicate abandonment]
  VULNERABILITY_SURFACE:[Does this component handle auth, payments, PII,
                        external input, file uploads, or other security-
                        sensitive operations?]
  LICENSE_RISK:         [Any dependencies with restrictive licenses?
                        GPL, AGPL, SSPL, unknown, or no license]
  EOL_DEPENDENCIES:    [Dependencies at end of life or no longer maintained]
```


## Risk-Specific Templates

### LIABILITY REGISTER

```
LIABILITY_ID:          [liability].[sequential_number]
CATEGORY:              [SECURITY | COMPLIANCE | FINANCIAL | OPERATIONAL |
                        LEGAL | REPUTATIONAL]
DESCRIPTION:           [What is the liability?]
SEVERITY:              [CRITICAL | HIGH | MEDIUM | LOW]
EVIDENCE:              [RULE_IDs, COMPONENT_IDs, DEP_IDs that substantiate]
CURRENT_MITIGATION:    [What currently prevents this from causing harm?]
MITIGATION_FRAGILITY:  [How easily could the current mitigation fail?]
REMEDIATION_EFFORT:    [DAYS | WEEKS | MONTHS — rough estimate]
REMEDIATION_RISK:      [Could fixing this introduce new problems?]
```


### MAINTAINABILITY SCORECARD

One per codebase, aggregated from component-level analysis.

```
MAINTAINABILITY:
  OVERALL_SCORE:       [A-F letter grade with justification]
  COMPREHENSIBILITY:   [Can a new developer understand this in a reasonable
                        time? Score 1-5 with evidence]
  MODIFIABILITY:       [Can changes be made safely? Score 1-5 with evidence]
  TESTABILITY:         [Can behavior be verified? Score 1-5 with evidence]
  OPERABILITY:         [Can this be deployed, monitored, debugged in
                        production? Score 1-5 with evidence]
  BUS_FACTOR:          [Aggregate — how many people could maintain this?]
  DOCUMENTATION_QUALITY:[GOOD | STALE | MISLEADING | ABSENT]
  ONBOARDING_ESTIMATE: [How long for a competent developer to become
                        productive? Days/weeks/months]
```


### KEY-PERSON RISK MAP

```
PERSON_RISK_ID:        [person_risk].[sequential_number]
KNOWLEDGE_DOMAIN:      [What area of the codebase is concentrated?]
COMPONENTS_AFFECTED:   [COMPONENT_IDs with concentrated authorship]
RISK_IF_UNAVAILABLE:   [What happens if this person leaves or is unavailable?]
KNOWLEDGE_TRANSFER:    [Is there documentation? Another person who knows?
                        Or is this purely tribal knowledge?]
MITIGATION:            [Pair programming, documentation sessions, cross-training]
```


## Lens-Specific Report Section

Add to the LENS_SPECIFIC field of the ARCHAEOLOGY REPORT:

```
RISK_SUMMARY:
  CRITICAL_LIABILITIES:[Count and brief list]
  COMPLIANCE_GAPS:     [Rules that should be auditable but aren't]
  SECURITY_SURFACE:    [Components handling sensitive operations without
                        adequate protection]
  KEY_PERSON_RISKS:    [Count of single-point-of-knowledge areas]
  EOL_DEPENDENCIES:    [Count of end-of-life or unmaintained dependencies]
  LICENSE_RISKS:       [Dependencies with problematic licenses]
  MAINTAINABILITY:     [Overall letter grade]
  ESTIMATED_REMEDIATION:[Rough total effort to address CRITICAL and HIGH items]
  DEAL_BREAKERS:       [Issues severe enough to reconsider the objective —
                        state plainly or state NONE]
```
