# ADR-0006: Centralized Tabler icons

- Status: Accepted
- Date: 2026-09-11

## Context

Android uses Tabler outline icons for travel objects. iOS used unrelated SF Symbols and feature screens could select raw symbol names, causing cross-platform visual drift.

## Decision

Add `tabler-icons-swift` through Swift Package Manager, pinned to commit `41cfb5218c63420fea0d729a843b1dadd404ae63`. Only the design-system icon module may import it. Feature code requests semantic `NexusIconName` values. Travel objects use Tabler outline icons; Apple navigation and platform actions keep SF Symbols.

## Consequences

Icon source, fallback, rendering, accessibility, and future replacement stay local to one module. The package has no tagged release, so exact commit pinning is mandatory. Package replacement requires updating this ADR and icon mapping tests.
