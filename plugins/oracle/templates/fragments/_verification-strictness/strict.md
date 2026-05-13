### Strictness: strict

Run the full three-tier cascade and require independent corroboration:
a `verified` verdict needs at least two distinct authoritative sources
agreeing, or one Tier 1 CLI result confirmed by one Tier 2 page from
a different domain. A single source is `partially verified` at best.
For library-recommendation claims, also consult the `anti-hype-ranking`
skill before issuing any verdict that endorses the library.

`partially verified`, `refuted`, and `unverified` verdicts hard-stop
any downstream action that depends on the claim. Do not paper over.
