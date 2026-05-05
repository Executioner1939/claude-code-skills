---
name: atomic-design
description: Brad Frost's atomic design methodology — atoms, molecules, organisms, templates, pages — applied to component libraries. Load whenever the task involves classifying, organizing, naming, splitting, merging, or auditing UI components, building a design system, deciding which level a new component belongs to, or reasoning about component composition. Auto-activates when working with files in atomic-design folder layouts (atoms/, molecules/, organisms/, templates/, pages/) or with any file ending in `.stories.*` or under a `design-system/` or `ui/` directory. Use for "where does this component go", "is this an atom or a molecule", "split this organism", "merge these atoms", "is this design system well-organized" type questions.
when_to_use: Component classification, design system organization, component refactoring decisions, story file taxonomy, naming conventions, deciding when a thing is reusable vs. one-off, atomic-level boundaries, design system audits.
paths: "**/*.stories.*, **/atoms/**, **/molecules/**, **/organisms/**, **/templates/**, **/pages/**, **/design-system/**, **/components/**, **/ui/**"
---

# Atomic Design

Reference for **Brad Frost's atomic design methodology**, applied to working component libraries (React / Vue / Svelte / web components — the methodology is framework-agnostic).

## The five levels

Atomic design organizes interfaces into a five-level hierarchy. Each level is **composed of the levels below it** and only the levels below it.

### 1. Atoms

The smallest indivisible UI building blocks. **One concern. One element (or near to it).** Cannot be broken down further without losing meaning.

Canonical examples:
- `Button`, `Input`, `Label`, `Icon`, `Avatar`, `Badge`, `Spinner`, `Heading`, `Text`, `Link`, `Checkbox`, `Radio`, `Switch`, `Tag`, `Divider`, `Skeleton`

Rules:
- An atom **renders one logical UI element** (a button is a button; even if it has an icon slot, the wrapper is still one button).
- Atoms **never compose other atoms** structurally. A `LabeledInput` is *not* an atom — it's a molecule.
- Atoms own only **their own** state (focus, hover, pressed) — never application state.
- Atoms accept design tokens, not hardcoded values.

If a "button" has its own dropdown menu inside, it has stopped being an atom. It is at minimum a molecule (`MenuButton`).

### 2. Molecules

**Small, purposeful groupings of atoms** that function together as a unit. A molecule has a single, focused job.

Canonical examples:
- `SearchBar` (Input + Button + Icon)
- `FormField` (Label + Input + HelperText + ErrorText)
- `Breadcrumb` (Link + Separator + Link + …)
- `Card` (Image + Heading + Text + Button) — when shallow
- `Toast` (Icon + Text + CloseButton)
- `Tag` with delete (Tag atom + IconButton)
- `Pagination` (IconButton + Button×n + IconButton)

Rules:
- A molecule does **one thing**. If you can't describe its purpose in one short sentence, it's probably an organism.
- Molecules are still **highly reusable**. They should not contain page-specific logic.
- Molecules can own **interaction state** (open/closed, selected, focused index) but not domain state.
- A molecule may compose multiple atoms of the same type (e.g. `RadioGroup` composes many `Radio` atoms).

### 3. Organisms

**Distinct sections of an interface**, composed of molecules and/or atoms (and sometimes other organisms). Organisms can stand alone as recognizable parts of a UI.

Canonical examples:
- `Header` / `NavBar` (Logo + NavLinks molecule + SearchBar + Avatar)
- `ProductCard` (Image + Heading + PriceTag molecule + Rating molecule + AddToCartButton)
- `DataTable` (Filters molecule + TableHeader + TableRow×n + Pagination)
- `CommentThread` (Comment molecule × n)
- `CheckoutSummary`, `Sidebar`, `Footer`, `HeroSection`

Rules:
- Organisms are still **reusable** but typically less so than molecules — they often have a clearer "intent".
- Organisms **may own domain state** (selected row, sort column, filter values) and may talk to data sources, but **do not own routing or page lifecycle**.
- An organism is the right level for **most "feature" components**. Resist the urge to skip this level and put feature logic into pages.

### 4. Templates

**Page-level layouts, with content slots, but without real content.** Templates define structure and grid placement.

Canonical examples:
- `DashboardTemplate` (Sidebar slot + Header slot + Main slot)
- `ArticleTemplate` (Hero slot + Body slot + RelatedArticles slot)
- `TwoColumnTemplate`, `CenteredFormTemplate`

Rules:
- Templates are **layouts**. They wire organisms / molecules into a page shape via slots, grid, or composition props.
- Templates **do not fetch data**. They do not own page-level state.
- A template renders identically whether you give it real content or placeholder content.

### 5. Pages

**Specific instances of templates, populated with real content and connected to data.**

Canonical examples:
- `UserDashboardPage` (uses `DashboardTemplate`, fetches user, renders organisms)
- `ProductDetailPage`, `LoginPage`, `SettingsPage`

Rules:
- Pages are where **routing**, **data fetching**, **side effects**, **page-level state** live.
- Pages are **least reusable** by design. They are the leaves of the tree.
- A page should mostly be glue: data → template → organisms.

## Decision rules: "what level is this?"

When in doubt, ask in this order:

1. **Is it a single element with one concern?** → Atom.
2. **Is it a small group of atoms with one job?** → Molecule.
3. **Is it a recognizable, standalone section of a UI?** → Organism.
4. **Is it a layout with slots but no content?** → Template.
5. **Is it routed, data-connected, and specific?** → Page.

If something feels like it sits between two levels:
- A molecule that grows complex domain state → it's becoming an organism. Promote it.
- An organism that is layout-only with slots → it's becoming a template. Promote it.
- A "molecule" that is just one atom with a wrapper → it's not a molecule. Inline it or make it a variant of the atom.

## Common pitfalls

- **Naming-by-vibe.** "ButtonGroup" sounds like a molecule because of the word "group", but a single button-with-dropdown is also a molecule. Classify by structure, not name.
- **Atom inflation.** Treating any small component as an atom. A `LabeledInput` is not an atom; it composes `Label` + `Input`. Make it a molecule.
- **Organism orphans.** Skipping the organism level and dumping organism-level concerns into pages. Pages then become unreusable mega-components.
- **Template = container.** Treating templates as just any wrapper component. A template is a *page-shaped* layout. If it's not page-shaped, it's a layout molecule/organism, not a template.
- **Shared-state leakage.** Atoms or molecules that read from a global store. Composition breaks the moment they're used in a different store context. Push state up to organisms or pages; pass values down.
- **Hardcoded design values.** Atoms and molecules with literal hex colors, pixel values, or font sizes. They must consume tokens — see the `design-tokens` skill.

## Folder layout

A working atomic-design layout for a component library:

```text
src/
└── components/
    ├── atoms/
    │   ├── Button/
    │   │   ├── Button.tsx
    │   │   ├── Button.stories.tsx
    │   │   ├── Button.mdx
    │   │   └── Button.test.tsx
    │   └── …
    ├── molecules/
    │   ├── SearchBar/
    │   ├── FormField/
    │   └── …
    ├── organisms/
    │   ├── Header/
    │   ├── DataTable/
    │   └── …
    ├── templates/
    │   └── DashboardTemplate/
    └── pages/
        └── UserDashboardPage/
```

Each component lives in its own folder. The folder is the unit of reuse, deletion, and review.

## Library obligations per atomic level

Each level has obligations from the `approved-libraries` policy and `tanstack-integration` patterns:

| Level | Required integrations |
|---|---|
| **Atom** (interactive) | Field-friendly prop shape: `value` + `onChange(value)` + `onBlur` + `aria-invalid` + `aria-describedby` + forwarded ref. Drops into a TanStack Form `field`. |
| **Atom** (non-interactive) | Tokens-only styling. Lucide for icons. |
| **Molecule** (form-shaped) | Accepts a TanStack Form `field` as primary prop. Renders error UI from `field.state.meta.errors` with correct ARIA wiring. |
| **Organism** (table) | Accepts a TanStack Table `table` instance, not raw `data + columns`. Uses TanStack Virtual when row count is unbounded. |
| **Organism** (list / grid with fetched data) | Consumes a TanStack DB collection (preferred — reactive, joinable) or a TanStack Query result (read-only). No bespoke `useState([])` for fetched data. |
| **Organism** (animated) | Motion (web) or Reanimated (native). Respects `prefers-reduced-motion`. |
| **Template / Page** | Routing is page-level only: TanStack Router (web) or Expo Router (React Native / native). MSW handlers in stories for fetch states. |

These are enforced by `audit-atomic`, `audit-molecules`, `audit-organisms`, and `audit-libraries`. Bypassing the listed integration = hygiene fail.

## Relationship to other skills in this plugin

- **`storybook-atomic-integration`** — defines what stories every component must have, broken out by atomic level. Read this when writing or auditing stories.
- **`design-tokens`** — atoms and molecules consume tokens; this skill defines the token taxonomy.
- **`approved-libraries`** — the bouncer-list of libraries components are required to use (or forbidden from using).
- **`tanstack-integration`** — the prop shapes and patterns that make components compose with TanStack Form / Table / DB / etc.
- **`component-composition`** — patterns (slots, compound, polymorphic) for composing higher levels from lower ones.
- **`story-coverage-checklist`** — the per-level rubric for "complete" Storybook coverage.

## Further reading

- Brad Frost, *Atomic Design* — https://atomicdesign.bradfrost.com/
- *Pattern Lab* — the original tooling for atomic design.
- Storybook's "Component Driven UI" guide — https://www.componentdriven.org/
