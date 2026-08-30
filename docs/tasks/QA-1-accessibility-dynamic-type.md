# QA-1 — Accessibility and Dynamic Type pass

## Goal

Audit every shipped SwiftUI screen and shared design-system control, then fix confirmed accessibility and Dynamic Type defects without changing product behavior or Android-defined visual tokens.

## Truth sources

- All shipped iOS `Sources/Feature/**` screens and `Sources/Core/DesignSystem/**` components.
- Android matching feature screens and design-system components for visible content and hierarchy.
- Apple platform accessibility behavior; Android remains visible product/design truth.
- Existing `PORTING.md`, `CONVENTIONS.md`, and completed task packets.

## Required behavior

- Icon-only controls have concise labels; decorative images stay hidden; compound cards expose one useful element and correct button/header traits.
- Every actionable control meets project touch-target tokens and exposes selected, disabled, loading, error, and progress state meaningfully.
- Large accessibility text does not clip essential copy or hide actions; horizontal rows may reflow vertically where needed.
- Screen headings, error/status announcements, form labels, hints, values, and focus order remain useful with VoiceOver.
- Reduce Motion, Increased Contrast, and Reduce Transparency behavior stays intact; motion implementation remains QA-2 scope.
- No copy, navigation, backend, persistence, or domain behavior changes beyond accessibility wording needed for accurate assistive output.

## Tests/evidence

- RED first for any reusable behavior that can be covered without rendering SwiftUI; compile-time/view inspection backs declarative modifier fixes.
- Adversarial pass across every shipped screen and shared control; record confirmed findings and resolutions in PR evidence.
- Latest PR-head macOS CI green. Simulator and real-device VoiceOver/large-text evidence linked when available; otherwise explicitly deferred, never claimed verified.

## Owned paths

- `Sources/Feature/**` SwiftUI screen files.
- `Sources/Core/DesignSystem/**` shared controls/tokens only where confirmed defect is shared.
- Matching focused tests, `PLAN.md`, `ARCHIVE.md`, and this packet.

## Excluded

- Motion redesign (QA-2), network/retry/performance behavior (QA-3), new product features, backend edits, third-party dependencies, and visual redesign.
