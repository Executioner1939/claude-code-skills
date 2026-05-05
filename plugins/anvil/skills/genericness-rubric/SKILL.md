---
name: genericness-rubric
description: This skill should be used when the user asks to "score genericness", "find wrapper components", "detect domain-prefixed components", "boil-down test", "is this a real primitive", "should this component exist", "merge into a canonical primitive", "audit thin wrappers", or whenever the audit pipeline (audit-atoms / audit-molecules / audit-organisms) needs to determine whether a component is a generic primitive, a thin wrapper of one, or a domain-prefixed shell that should be renamed and slotted. Provides the fifth scoring axis consumed by atomic-auditor and the canonical primitives registry shared with component-deduplicator and component-composer.
when_to_use: Auditing whether a component should exist as itself, deciding DELETE vs RENAME-AND-SLOT vs MERGE-INTO-PRIMITIVE vs PROMOTE-TO-PRIMITIVE, finding domain-prefixed shells (BookingWizard, BrandHero, KnownForChip, WishlistButton), proving an "atom" is really a wrapper of an existing primitive, generating boil-down expressions for codemod input, sharing a canonical primitives registry across auditor / deduplicator / composer agents.
paths: "**/components/**, **/atoms/**, **/molecules/**, **/organisms/**, **/templates/**, **/.storybook-atomic.yml"
---

# Genericness Rubric

The fifth axis. Atomic-design says *what level* a component sits at. Genericness says *whether the component should exist at itself at all*, or whether it is a thin domain-prefixed wrapper of a primitive that already lives in the design system.

> A component achieves an atomic-design level by **being generic**, not by **living in the right folder**.

## Genericness axis (0–100)

Five sub-scores, summed:

| Sub-score | Weight | Pass condition |
|---|---|---|
| Name is function-shaped, not domain-shaped | 25 | Name does not match the domain-prefix regex below |
| Accepts slots / children / render-prop / `as` / `asChild` | 25 | Slot-acceptance test passes |
| Adds real behavior over the inner primitive | 20 | Boil-down test FAILS (i.e. component is not a pure wrapper) |
| Has ≥ 1 sibling-cluster of similar shape | 15 | If clusters exist, the component is the canonical name; if no clusters, full marks |
| Listed in the canonical primitives registry | 15 | Either listed, OR adds genuine domain behavior on top of a registry primitive |

Letter grade: A ≥ 90, B ≥ 80, C ≥ 70, D ≥ 60, F < 60.

## Domain-prefix detection

A component name matches `<DomainWord><PrimitiveSuffix>` when both halves resolve from these lists. Both lists are extensible per project via `.storybook-atomic.yml`.

```
^(Booking|Cart|Checkout|Order|Licence|License|KYC|Brand|Award|Wishlist|Hero(?!$)|Sign|Account|Cookie|Subscription|Payment|Promo|Trust|Ecosystem|Platform|Marketing|Pricing|Session|Shipping|Filter(?=Rail|Sheet)|Connected|Review|KnownFor)(Card|Tile|Tier|Strip|Rail|Bar|Item|Row|Wizard|Hero|Form|Drawer|Sheet|Dialog|Picker|Group|Selector|Banner|Badge|Pip|Chip|Button|Link|Icon|Notice)$
```

`Hero(?!$)` matches `HeroSimple`, `HeroGlobe`, etc., but not bare `Hero`. `Filter(?=Rail|Sheet)` only fires for `FilterRail` / `FilterSheet`.

A match is a *suspicion*, not a verdict. Combine with the slot-acceptance test and the boil-down test before issuing a verdict.

## Slot-acceptance test

A component **passes** if it accepts at least one of:

- `children` (renders within structure)
- a `content` prop typed `ReactNode | ((ctx) => ReactNode)`
- a `slots` object (named multi-region)
- a `render` / `renderItem` / `renderRow` prop
- a `steps[]` / `items[]` / `groups[]` array of `{id, …, content}` entries
- polymorphic `as` or `asChild` (Radix-style)

A component that hardcodes its inner JSX with no escape hatch is a leaky abstraction. Slot-acceptance failure on a domain-prefixed component is strong evidence for RENAME-AND-SLOT or DELETE.

## Boil-down test

Read the component body. The test **passes** (= component is a pure wrapper, candidate for DELETE) when **all** are true:

- JSX renders exactly one `<GenericPrimitive {...passthroughProps}>{slottedChildren}</GenericPrimitive>` (the registry primitive at the root).
- No `useState`, `useReducer`, `useEffect`, `useLayoutEffect`, `useId`, or other behavior hook.
- No event handler beyond identity passthrough.
- No derived state (`useMemo`, `useCallback` with non-trivial deps).
- No imperative `ref` work, no `useImperativeHandle`.
- No accessibility announcements, focus management, or keyboard handlers added.
- No conditional class names beyond static variant lookup.

A passing boil-down means: every consumer could replace the wrapper with the registry primitive without losing anything.

## Canonical primitives registry

The design system's primitives that domain shells should compose. Project-overridable in `.storybook-atomic.yml` under `genericness.registry`.

| Primitive | Replaces |
|---|---|
| `Wizard<TData>` (steps[], header/footer/progress slots) | BookingWizard, LicenceApplication, KYCStatus, CheckoutShell |
| `Stepper` | inline step indicators |
| `Hero` (media / eyebrow / title / body / actions) | HeroSimple, BrandHero, HeroGlobe |
| `Card` (header / media / body / footer) | BrandCard, LicenceCard, PricingTier, MarketingFeatureTile, PlatformCard |
| `Modal`, `Drawer`, `Sheet`, `Dialog` | domain-prefixed dialogs |
| `Chip`, `Badge`, `Pip`, `Tag` | KnownForChip, status pips, category tags |
| `IconButton`, `Button`, `Link`, `Icon` | WishlistButton, SocialLink, ServiceIcon |
| `Divider`, `Text` | GoldRule, Eyebrow |
| `FilterPanel` (groups[]) | FilterRail, FilterSheet |
| `ListItem` (leading / title / subtitle / trailing) | ConnectedAccountItem, PaymentMethodItem, OrderCard, SessionListItem |
| `SummaryCard`, `LineItemList`, `TotalRow` | bespoke order/cart summaries |
| `OptionPicker` / `RadioCardGroup` | TimeSlotPicker, SessionTypeCardGroup, ShippingMethodPicker, PlatformPicker |
| `LogoStrip` | BrandStrip, EcosystemRail, TrustStrip |
| `MediaCard`, `ChipBar` | inline media/chip layouts |

## Verdict vocabulary (per component)

| Verdict | Meaning | Trigger |
|---|---|---|
| `PASS` | Component is itself a registry primitive, OR is a domain shell that adds real behavior/state. | Slot-acceptance ✓ AND (in registry OR boil-down FAILS). |
| `DELETE` | Pure wrapper of a registry primitive. Inline call sites and remove. | Boil-down PASSES AND inner element is a registry primitive. |
| `RENAME-AND-SLOT` | Domain-prefixed but adds slottable structure; rename to canonical name + expose slots. | Domain-prefix ✓ AND slot-acceptance ✓ AND not in registry. |
| `MERGE-INTO-PRIMITIVE` | Has ≥ N siblings of same shape; create canonical primitive and collapse all N. | Sibling-cluster present (component-deduplicator output ≥ 2 members same cluster). |
| `PROMOTE-TO-PRIMITIVE` | Right structure, wrong name. Rename only; no API change. | Slot-acceptance ✓ AND boil-down FAILS AND name is domain-prefixed AND no siblings. |

## Boil-down expression

When the verdict is `DELETE` or `MERGE-INTO-PRIMITIVE`, emit a one-line replacement expression so a downstream codemod has the data it needs:

- `KnownForChip → <Chip>{value}</Chip>`
- `WishlistButton → <IconButton variant="toggle" pressed={pressed} onPressedChange={onPressedChange} aria-label="Save to wishlist" />`
- `BrandStrip → <LogoStrip items={brands} />`
- `BookingWizard → <Wizard steps={bookingSteps} header={<BookingHeader />} />`
- `Eyebrow → <Text variant="eyebrow">{children}</Text>`
- `GoldRule → <Divider tone="gold" />`

Format: `<ComponentName> → <JSX expression>` on one line. Props on the right side use the actual prop names from the wrapper.

## Output contract (auditor GENERICNESS block)

The `atomic-auditor` agent emits this block per component, slotted between the existing HYGIENE and COMPOSITE blocks. Format mirrors the existing axes (see `plugins/anvil/agents/atomic-auditor.md` lines 54–101) so downstream parsers do not change shape:

```text
  GENERICNESS  <n>/100   <letter>   <VERDICT>
    name        ✅|❌  function-shaped (domain-prefix match: <none|BrandCard matches Brand+Card>)
    slots       ✅|❌  accepts <children|content|slots|render|steps[]|as|asChild|none>
    boil-down   ✅|❌  <pure-wrapper of <Primitive>|adds <list of behavior signals>>
    cluster     <none|cluster-N: <member, member, ...>>
    registry    ✅|❌  <listed as <Primitive>|not listed; nearest = <Primitive>>
    boil-down expression: <ComponentName> → <JSX>
```

A `VERDICT` of `DELETE`, `MERGE-INTO-PRIMITIVE`, or `RENAME-AND-SLOT` MUST appear in the per-component RECOMMENDED ACTIONS list. A `PROMOTE-TO-PRIMITIVE` produces a rename action only.

## Project overrides

`.storybook-atomic.yml` may override:

```yaml
genericness:
  domain_words: [Booking, Cart, Checkout, ...]   # extends, does not replace, the default list
  primitive_suffixes: [Card, Tile, Tier, ...]    # extends the default list
  registry:                                      # adds primitives or remaps replacements
    Wizard: { replaces: [BookingWizard, ...] }
  weights:                                       # override sub-score weights (must sum to 100)
    name: 25
    slots: 25
    behavior: 20
    cluster: 15
    registry: 15
```

The auditor surfaces overrides at the top of the report (same convention as the existing `.storybook-atomic.yml` handling — see `atomic-auditor.md:138`).

## Cross-references

- **`atomic-design`** — decides what level a component sits at. This skill is the missing test that proves the level was *earned by genericness*, not by folder.
- **`component-composition`** — the toolbox of patterns (slots, compound, polymorphic, headless+skin) that a component must be using to pass the slot-acceptance test. RENAME-AND-SLOT verdicts cite specific patterns from this skill.
- **`component-cartographer`** (agent) — produces the inventory the cluster sub-score reads.
- **`component-deduplicator`** (agent) — its similarity clusters feed the `cluster` line in the output block; it shares this skill's canonical primitives registry as its single source of truth.
- **`component-composer`** (agent) — its pre-flight registry lookup consults the canonical primitives registry above before any `BUILD-NEW` verdict.
- **`atomic-auditor`** (agent) — emits the GENERICNESS block defined in the Output contract section above.

## Further reading

- Brad Frost, *Atomic Design*, "Pattern Lab" — establishes the level taxonomy this rubric tests.
- Radix UI primitives, `asChild` polymorphism — the canonical example of slot-accepting primitives.
- "Naming components after function, not content" — the deeper principle this rubric mechanizes.
