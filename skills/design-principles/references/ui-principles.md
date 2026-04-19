# UI Principles

Based on Joshua Porter's *Principles of User Interface Design* (bokardo.com). The titles are Porter's; the commentary is condensed and rewritten for application. Use these when designing or reviewing individual screens and components.

## 1. Clarity is job #1

Users must recognize what the interface is, understand why they would use it, and predict what will happen when they interact. There's room for delight; there's no room for confusion. Prefer a hundred clear screens to a single cluttered one. When in doubt between "elegant and ambiguous" and "boring and obvious," pick obvious.

## 2. Interfaces exist to enable interaction

A UI is not an art object. It does a job, and its effectiveness can be measured. This doesn't mean it should be dry — the best interfaces still evoke feeling — but it does mean "looks cool" alone is never a complete argument.

## 3. Conserve attention at all costs

Attention is scarce. Don't bury the reading experience under ads, modals, or attention-grabs. If someone is doing the thing your product exists for, don't interrupt them.

## 4. Keep users in control

Surface system state. Explain causation ("doing X will cause Y"). Set expectations before an action, confirm after. People feel safe when they know what's happening and what's next. State the obvious — it is rarely as obvious as you think.

## 5. Direct manipulation is best

The best interface is none at all. When it must exist, make it feel like manipulating the object of focus rather than manipulating UI *about* the object. Minimize chrome, modes, and layers.

## 6. One primary action per screen

Each screen should have a single main thing you want the user to do — its reason for existing. Two co-equal primary actions is usually a sign the screen should be split.

## 7. Keep secondary actions secondary

Screens can have multiple actions, but the secondary ones must look secondary: lighter weight, lower contrast, further away, or revealed only after the primary action succeeds. Sharing buttons shouldn't compete with the content being shared.

## 8. Provide a natural next step

Few interactions are meant to be the last. After the user finishes the primary action, offer a sensible next step. Don't drop them onto a blank screen with nowhere to go.

## 9. Appearance follows behavior

Things should look how they behave. A button should look like a button and act like a button. Don't reinvent basic controls; save creativity for higher-order concerns.

## 10. Consistency matters

Things that behave the same should look the same. Things that behave differently should look different. Novice designers often flatten real differences by reusing a component for visual convenience — that's worse than inconsistency, because it hides the difference.

## 11. Strong visual hierarchies work best

A strong hierarchy means users view the same elements in the same order every time. Weak hierarchies feel cluttered because the eye has nowhere to land. Visual weight is relative — adding one heavy element can force you to reset everything else.

## 12. Smart organization reduces cognitive load

Group related things. Use spatial placement to imply relationships. Don't make users compute the structure — encode it into the layout.

## 13. Highlight, don't determine, with color

Color guides attention; it shouldn't be the *only* differentiator. Accessibility and colorblindness aside, color shifts by context and display. Use muted backgrounds for long reading, save vivid colors for accents.

## 14. Progressive disclosure

Show only what's needed for the current decision. Defer detail to subsequent screens or expansions. Over-explaining up front is a form of clutter.

## 15. Help people inline

Contextual help where and when needed, invisible the rest of the time. Forcing users to leave the task to consult docs means they have to already know what to ask.

## 16. The zero state is a crucial moment

Empty states are not blank canvases — they're the first impression and onboarding combined. Design them deliberately with direction, example data, or a clear first action.

## 17. Great design is invisible

If it works, users forget the UI and focus on their goal. As a designer, expect less praise for good work than for flashy work. That's fine.

## 18. Build on other design disciplines

Typography, information architecture, copywriting, data visualization — all are part of interface design. Don't gatekeep. Pull insight from unrelated fields (publishing, code, games, physical products) freely.

## 19. Interfaces exist to be used

A beautiful interface nobody uses has failed. Designing for use means designing the environment around the interface, not just the artifact itself.

## Applying these in practice

When reviewing a design, try this sequence:

1. **Clarity check** — Can a first-time user name the primary action within two seconds?
2. **Hierarchy check** — Squint at the screen. Does one element clearly dominate?
3. **Consistency check** — Do things that behave the same look the same? Do things that behave differently look different?
4. **Next-step check** — What happens after the user finishes the primary action?
5. **Zero-state check** — What does this screen look like for a brand-new user with no data?

If any of these reveal a weakness, name it using the corresponding principle — that turns the critique into something the team can act on.

---

*Source: Joshua Porter, [Principles of User Interface Design](http://bokardo.com/principles-of-user-interface-design/), bokardo.com.*
