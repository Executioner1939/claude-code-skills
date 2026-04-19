---
name: design-principles
description: Curated reference library of canonical design principles covering user interface design, product design, and enduring classics (Dieter Rams, Joshua Porter, Bruce Tognazzini, inclusive design, plus foundational laws like Postel's robustness principle and the principle of least surprise). Use this skill whenever building, reviewing, or critiquing any user-facing surface — a screen, component, page, dashboard, landing page, form, or full product — and whenever making product tradeoff calls (what to build, what to cut, how to prioritize, how to position). This applies even when the user does not explicitly say "design principles" — any task involving UI generation, UX review, PR feedback on frontend work, wireframe critique, choosing between design alternatives, or writing microcopy for empty states and errors should consult this skill. The principles serve as a checklist and vocabulary to ground design reasoning in established craft rather than defaulting to generic AI aesthetics.
---

# Design Principles

A compact reference library of canonical design principles. Consult it whenever design judgment is part of the task.

## When to consult

Load references from this skill when the task involves:

- Building or reviewing a UI — a screen, component, page, dashboard, form, or flow
- Giving feedback on frontend PRs or mockups
- Making product decisions — what to build, what to cut, how to prioritize, how to position
- Weighing tradeoffs — density vs. clarity, flexibility vs. simplicity, automation vs. user control
- Answering questions like "is this a good design?", "should we show this here?", "what should the empty state look like?"
- Writing microcopy — empty states, onboarding, error messages, CTAs, confirmations

You do not need to cite principles verbatim in responses. Internalize them and apply them. When a design choice feels off, reach for a principle to articulate *why* — that turns vague taste into reviewable reasoning.

## How to use the references

Full principle sets live in `references/` to keep this main file light. Load the file that matches the task:

- **`references/ui-principles.md`** — Joshua Porter's principles for interface-level decisions: clarity, primary actions, visual hierarchy, consistency, zero state, progressive disclosure. Load when designing or reviewing **screens and components**.
- **`references/product-principles.md`** — Joshua Porter's principles for product-level decisions: usefulness, focus, fit-and-finish, competition, positioning, product-market fit. Load when making **scope and strategy** calls.
- **`references/timeless-principles.md`** — Dieter Rams' ten, Bruce Tognazzini's first principles of interaction design, inclusive design tenets, and foundational laws (Postel's robustness, Pareto, DRY, principle of least surprise). Load for **crosscutting judgment** that applies to nearly any design task.
- **`references/further-reading.md`** — Source links and additional curated collections for deeper research when a task warrants it.

For a tiny task (tweaking one button's padding), skip the references. For anything substantive — a full screen, a feature PR, a product critique, a design argument — load the relevant file up front so the reasoning is grounded.

## Applying principles well

Principles are heuristics, not laws. Three things to remember:

1. **They conflict.** "Progressive disclosure" and "keep users in control" often pull in opposite directions. "Smaller, better product" and "provide a natural next step" can collide. When two principles point different ways, name the tension explicitly and make a deliberate call for the specific context — don't just grab the nearest rule.
2. **They are diagnostic, not generative.** Principles are best at telling you *why an existing design is weak* rather than dictating what to build from scratch. Use them to critique, not to auto-generate.
3. **Context beats doctrine.** A dashboard for professional traders violates "one primary action per screen" on purpose. A consumer onboarding flow should not. Know which context you are in before applying any rule strictly.

## Relationship to other skills

If `frontend-design` is also loaded and the task involves building actual frontend code, use both: `frontend-design` covers *how to implement* (design tokens, Tailwind patterns, component structure); this skill covers *why a design works or doesn't*. The two compose — critique the design with these principles, then build it with `frontend-design`.
