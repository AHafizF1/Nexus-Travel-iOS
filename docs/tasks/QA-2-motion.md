# QA-2 — Motion audit, plans, and later execution

## Goal

Audit shipped motion against Android code truth and Apple interaction rules, write self-contained plans, then execute only confirmed high-leverage fixes with Reduce Motion support.

## Truth sources

- All iOS `Sources/**` motion, transition, loading, navigation, and gesture code.
- Matching Android Compose animation code and `NexusMotion` tokens.
- Apple platform motion/accessibility rules, `PORTING.md`, and `CONVENTIONS.md`.

## Required behavior

- Motion serves feedback, orientation, continuity, or perceived performance; frequent actions remain restrained.
- Interactive motion is interruptible where applicable and uses native platform behavior before custom code.
- Shared durations remain Android-derived; springs are critically damped unless user momentum warrants bounce.
- Reduce Motion removes spatial movement but retains short opacity/state feedback.
- Audit precedes implementation; plans remain self-contained and commit-stamped.

## Tests/evidence

- Test-first for reusable motion values; declarative SwiftUI changes compile on latest PR-head CI.
- Adversarial source review confirms every cited finding at current file/line.
- Real-device feel checks remain explicit evidence; no performance or motion-quality claim from Windows.

## Owned paths

- `animation-plans/**`, confirmed motion call sites, design-system motion tokens, focused tests, PLAN/ARCHIVE, and this packet.

## Excluded

- Decorative motion, new gesture systems, product-flow changes, third-party dependencies, and QA-3 reliability/performance work.
