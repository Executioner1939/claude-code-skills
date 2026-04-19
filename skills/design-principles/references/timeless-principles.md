# Timeless Principles

Crosscutting principles and foundational "laws" that apply across UI, product, systems, and beyond. Load this file for any substantive design task — these show up everywhere.

## Dieter Rams — Ten Principles for Good Design

Rams articulated these for industrial design at Braun in the 1970s, but they transfer almost perfectly to software. Many of Apple's product-design sensibilities trace directly to them.

1. **Good design is innovative.** Innovation happens alongside new technology and is never an end in itself.
2. **Good design makes a product useful.** Usefulness is primary; aesthetics exist in service of it.
3. **Good design is aesthetic.** Well-executed objects are pleasing because well-being depends on things we use daily.
4. **Good design makes a product understandable.** At its best, the product explains itself.
5. **Good design is unobtrusive.** Products are tools, not decorations or self-expression for the designer.
6. **Good design is honest.** It doesn't manipulate, overpromise, or pretend to capabilities it lacks.
7. **Good design is long-lasting.** It avoids fashion so it doesn't feel dated. Timeless > trendy.
8. **Good design is thorough down to the last detail.** Nothing is arbitrary; care and precision at every level express respect for the user.
9. **Good design is environmentally friendly.** It conserves resources and minimises harm.
10. **Good design is as little design as possible.** "Less, but better." Concentrate on essentials; shed the unessential. Back to purity, back to simplicity.

### How to apply Rams in software

- **#4 Understandable** — if your onboarding needs a video, the product probably isn't explaining itself yet.
- **#5 Unobtrusive** — when a UI is proud of itself, the user notices the UI rather than the task. That's usually a regression.
- **#7 Long-lasting** — resist trend-driven restyles. Users pay the cost of relearning.
- **#10 As little as possible** — the most reliable design upgrade is removing something.

## Bruce Tognazzini — First Principles of Interaction Design

Tog's canonical set (from asktog.com) — foundational for any interactive system. Brief notes on each:

- **Aesthetics** — Visual form supports function; it is not decoration bolted on afterwards.
- **Anticipation** — Bring the user what they'll need next before they have to ask.
- **Autonomy** — Give users the tools and information to stay in control of their environment.
- **Color blindness** — Never encode meaning in color alone; ~8% of men can't distinguish red/green reliably.
- **Consistency** — Consistent behavior matters more than consistent appearance; don't confuse the two.
- **Defaults** — Sensible defaults do more for usability than most features. Most users never leave them.
- **Efficiency of the user** — The user's time is more valuable than the machine's. Optimise for their throughput, not yours.
- **Explorable interfaces** — Users should feel safe to try things. Undo is not optional.
- **Fitts's Law** — Time to hit a target is a function of distance and size. Bigger closer targets are faster. (Corners and edges are effectively infinite in size — that's why macOS menu bars sit at the screen top.)
- **Human interface objects** — Objects on screen should have consistent rules of behavior across contexts.
- **Latency reduction** — Mask latency with feedback. A 300 ms response with a progress indicator feels faster than 200 ms of blank screen.
- **Learnability** — Users should be able to build a working mental model quickly and extend it on their own.
- **Metaphors** — Metaphors help transfer knowledge but mislead when stretched. The "desktop" metaphor works until you try to extend it to everything.
- **Protect users' work** — Never lose data. Auto-save, confirmations before destructive actions, undo.
- **Readability** — Sufficient contrast, sufficient size, resistance to user-hostile styling trends.
- **Track state** — Remember what the user was doing across sessions, tabs, devices.
- **Visible navigation** — Users should always know where they are, where they came from, and how to leave.

## Inclusive Design Principles

Distilled from Sandi Wassmer and Heydon Pickering. Inclusive design is accessibility's bigger sibling — not just compliance, but designing so the widest variety of people can use the product well.

- **Equitable** — Don't create a "special" path for users with different needs; make the same path work for everyone where possible.
- **Flexible** — Provide options. Let people choose how to interact.
- **Straightforward** — Be obvious over clever.
- **Perceptible** — Don't assume a sense or capability the user might not have.
- **Tolerant** — Handle user errors without scolding or destroying their work.
- **Effortless** — Don't impose demands on users' bodies or cognition beyond what the task genuinely requires.
- **Accommodating** — Uncluttered layouts, generous hit targets, room to manoeuvre.
- **Consistent** — Follow platform conventions. Users learn them exactly once across many apps.
- **Involve code early** — Inclusive design is an implementation concern, not a visual-design afterthought.
- **Respect conventions** — Novel interactions carry a teaching cost. Use conventions unless breaking them buys something significant.

## Foundational Laws

Principles so general they apply far beyond UI — to APIs, systems, organizations, protocols.

### Postel's Law (Robustness Principle)

> Be conservative in what you send; be liberal in what you accept.

Originally about TCP, but it generalizes. When emitting data (API responses, UI events, log entries), be strict and well-formed. When ingesting data (user input, external APIs, file formats), be forgiving of minor deviation. The caveat: being *too* liberal on the accept side enables bad inputs to propagate and entrenches mistakes. Use with judgment.

### Principle of Least Surprise (Principle of Least Astonishment)

When two interpretations of an interaction are plausible, pick the one that would least surprise a reasonable user. Extends to APIs (function names should do what they sound like) and systems (error messages should describe the actual problem).

### DRY — Don't Repeat Yourself

> Every piece of knowledge must have a single, unambiguous, authoritative representation within a system.

Often misquoted as "don't repeat code," which is weaker. The real rule is about *knowledge* — business rules, truths, constraints. Duplicating code that happens to look similar but represents different knowledge is fine; duplicating a business rule in three places is a bug waiting to be inconsistent.

### The Pareto Principle (80/20)

Roughly 80% of effects come from 20% of causes. In product work: 20% of features drive 80% of usage; 20% of bugs cause 80% of support tickets; 20% of users generate 80% of revenue. Useful as a lens for prioritization — find the high-leverage 20% and invest there disproportionately.

### Hick's Law

Decision time grows with the number of choices. More options means slower decisions and higher abandonment. Grouping, defaults, and progressive disclosure are all responses to Hick's Law.

### Fitts's Law

Time to acquire a target is a function of distance to it and size of it. Practical implications: larger buttons for more important actions, put primary actions where the pointer already is, treat screen edges and corners as having effectively infinite size.

### Jakob's Law

Users spend most of their time on *other* sites and products. They expect your product to work like those do. Novel interactions are expensive to teach; conventional ones are free.

### Miller's Law (7 ± 2)

Short-term memory holds roughly seven items. Applied to UI: chunk long forms, long lists, long navigation. Applied to onboarding: don't introduce more than a handful of new concepts at once.

## When principles conflict

They will. Common tensions:

- **Progressive disclosure vs. keep users in control** — Hiding options simplifies, but also removes agency. Resolve by asking: which option, if the user doesn't find it, will make them blame the product?
- **Consistency vs. clarity** — A consistent pattern that's unclear in a specific context is worse than an inconsistent-but-obvious one. Consistency serves clarity, not the other way around.
- **Smaller better product vs. natural next step** — Cutting scope aggressively can leave users stranded with nowhere to go. Ship the minimum viable *next-step*, not just the minimum viable feature.
- **Accept liberally (Postel) vs. least surprise** — Accepting malformed input can produce surprising behavior downstream. Bias toward explicit errors over silent correction when the correction is ambiguous.

When principles conflict, name the tradeoff explicitly and commit. The conflict isn't a failure — it's the actual design decision being made visible.

---

*Sources: Dieter Rams' ten principles; Bruce Tognazzini, [First Principles of Interaction Design](https://asktog.com/atc/principles-of-interaction-design/); Sandi Wassmer, *Ten Principles of Inclusive Web Design*; Heydon Pickering, *What the Heck Is Inclusive Design*; Jon Postel (RFC 761); various.*
